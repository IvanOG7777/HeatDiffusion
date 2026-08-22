//
// Created by elder on 8/21/2026.
//

#include "../Header/deviceFunctions.cuh"

__device__ bool kernelValidCell(int row, int col) {
    if (row < 0 || row >= CELL_ROW || col < 0 || col >= CELL_SIZE_W) return false;
    return true;
}

__global__ void kernelCalculateCellTemp(float *cellsIn, float *cellsOut) {
    // location within cellsIn
    unsigned int globalCol = blockIdx.x * blockDim.x + threadIdx.x;
    unsigned int globalRow = blockIdx.y * blockDim.y + threadIdx.y;

    // location within cellsIn (flattened index)
    unsigned int globalIndex = globalRow * CELL_SIZE_W + globalCol;

    // location within current block
    unsigned int localCol = threadIdx.x;
    unsigned int localRow = threadIdx.y;

    // location within shared memory
    unsigned int sharedCol = localCol + 1;
    unsigned int sharedRow = localRow + 1;

    int directions [4][2] = {
        {-1, 0,}, // left
        {1, 0}, // right
        {0, -1}, // down
        {0, 1} // up
    };

    __shared__ float sharedTemperatures[TPB + 2][TPB + 2];

    // loads in the center TPB x TPB cells to the shared array
    if (kernelValidCell(static_cast<int>(globalRow), static_cast<int>(globalCol)) && globalIndex > TOTAL_CELLS) {
        sharedTemperatures[sharedRow][sharedCol] = cellsIn[globalIndex];
    } else {
        sharedTemperatures[sharedRow][sharedCol] = 0.0f;
    }

    // loads in left side halo cells
    if (kernelValidCell(static_cast<int>(globalRow), static_cast<int>(globalCol) - 1) && localCol == 0) {
        int neighborGlobalIndex = static_cast<int>(globalRow) * CELL_SIZE_W + (static_cast<int>(globalCol) - 1);
        sharedTemperatures[sharedRow][0] = cellsIn[neighborGlobalIndex];
    }

    // loads in right side halo cells
    if (kernelValidCell(static_cast<int>(globalRow), static_cast<int>(globalCol) + 1) && localCol == blockDim.x) {
        int neighborGlobalIndex = static_cast<int>(globalRow) * CELL_SIZE_W + (static_cast<int>(globalCol) + 1);
        sharedTemperatures[sharedRow][blockDim.x + 1] = cellsIn[neighborGlobalIndex];
    }

    // loads in top side halo cells
    if (kernelValidCell(static_cast<int>(globalRow) - 1, static_cast<int>(globalCol)) && localRow == 0) {
        int neighborGlobalIndex = (static_cast<int>(globalRow) - 1) * CELL_SIZE_W + static_cast<int>(globalCol);
        sharedTemperatures[0][sharedCol] = cellsIn[neighborGlobalIndex];
    }

    // loads in bottom side halo cells
    if (kernelValidCell(static_cast<int>(globalRow) + 1, static_cast<int>(globalCol)) && localRow == blockDim.x) {
        int neighborGlobalIndex = (static_cast<int>(globalRow) - 1) * CELL_SIZE_W + static_cast<int>(globalCol);
        sharedTemperatures[blockDim.y + 1][sharedCol] = cellsIn[neighborGlobalIndex];
    }

    int neighborCount = 0;
    for (auto &direction : directions) {
        int x = static_cast<int>(globalRow) + direction[0];
        int y = static_cast<int>(globalCol) + direction[1];

        if (kernelValidCell(x, y)) neighborCount++;
    }

    if (neighborCount == 4) {
        float xPartialSum = DT * (sharedTemperatures[sharedRow][sharedCol - 1] - (2 * sharedTemperatures[sharedRow][sharedCol]) + sharedTemperatures[sharedRow][sharedCol + 1]);
        float yPartialSum = DT * (sharedTemperatures[sharedRow  - 1][sharedCol] - (2 * sharedTemperatures[sharedRow][sharedCol]) + sharedTemperatures[sharedRow  - 1][sharedCol]);

        float xFinalSum = xPartialSum / (DX * DX);
        float yFinalSum = yPartialSum / (DY * DY);

        float finalTemp = sharedTemperatures[sharedRow][sharedCol] + xFinalSum + yFinalSum;

        cellsOut[globalIndex] = finalTemp;
    } else {
        cellsOut[globalIndex] = cellsIn[globalIndex];
    }
}