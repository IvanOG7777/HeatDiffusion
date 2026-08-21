//
// Created by elder on 8/20/2026.
//

#include "deviceFunctions.cuh"

__device__ bool kernelValidCell(int row, int col) {
    if (row < 0 || row >= CELL_SIZE_H || col < 0 || col >= CELL_SIZE_W) return false;
    return true;
}

__global__ void kernelCalculateCellTemp(float *cellsIn, float *cellsOut) {

    // global coordinate inside of entire grid
    unsigned int globalCol = blockIdx.x * blockDim.x + threadIdx.x;
    unsigned int globalRow = blockIdx.y * blockDim.y + threadIdx.y;
    unsigned int globalIndex = globalRow * CELL_SIZE_W + globalCol;

    // local coordinate inside of current block
    unsigned int localCol = threadIdx.x;
    unsigned int localRow = threadIdx.y;

    unsigned int sharedRow = localRow + 1;
    unsigned int sharedCol = localCol + 1;

    int directions [4][2] = {
        {-1, 0,},{1, 0}, // left, right
        {0, -1}, {0, 1} // down, up
    };

    int neighborCount = 0;
    int neighborCells[4] = {0};
    int index = 0;

    __shared__ float sharedTemperatures[TPB + 2][TPB + 2] = {0.0f};

    //loads normal interior cells
    if (kernelValidCell(static_cast<int>(globalRow), static_cast<int>(globalCol)) == true) {
        sharedTemperatures[sharedRow][sharedCol] = cellsIn[globalIndex]; // thread in shared memory coordinates
    } else {
        sharedTemperatures[sharedRow][sharedCol] = 0.0f;
    }

    // loads left col of halo cells
    if (kernelValidCell(static_cast<int>(globalRow), static_cast<int>(globalCol) - 1) && localCol == 0) {
        int neighborGlobalIndex = static_cast<int>(globalRow) * CELL_SIZE_W + (static_cast<int>(globalCol) - 1);
        sharedTemperatures[sharedRow][0] = cellsIn[neighborGlobalIndex];
    }

    // loads right col of halo cells                                                                 // threads we have in current block in col direction (16)
    if (kernelValidCell(static_cast<int>(globalRow), static_cast<int>(globalCol) + 1) && localCol == blockDim.x - 1) {
        int neighborGlobalIndex = static_cast<int>(globalRow) * CELL_SIZE_W + (static_cast<int>(globalCol) + 1);
        sharedTemperatures[sharedRow][blockDim.x + 1] = cellsIn[neighborGlobalIndex];
    }

    // loads top row of halo cells
    if (kernelValidCell(static_cast<int>(globalRow) - 1, static_cast<int>(globalCol)) && localRow == 0) {
        int neighborGlobalIndex = (static_cast<int>(globalRow) - 1) * CELL_SIZE_W + static_cast<int>(globalCol);
        sharedTemperatures[0][sharedCol] = cellsIn[neighborGlobalIndex];
    }

    // loads bottom row of halo cells                                                                     // threads we have in current blocks in row direction (16)
    if (kernelValidCell(static_cast<int>(globalRow) + 1, static_cast<int>(globalCol)) && localRow == blockDim.y - 1) {
        int neighborGlobalIndex = (static_cast<int>(globalRow) + 1) * CELL_SIZE_W + static_cast<int>(globalCol);
        sharedTemperatures[blockDim.y + 1][sharedCol] = cellsIn[neighborGlobalIndex];
    }
    __syncthreads();

    for (auto &direction : directions) {
        
    }
}