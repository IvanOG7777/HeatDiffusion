//
// Created by elder on 8/20/2026.
//

#include "deviceFunctions.cuh"

#include <float.h>

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

    __shared__ float sharedTemperatures[TPB + 2][TPB + 2] = {0.0f};

    //loads normal interior cells
    if (kernelValidCell(static_cast<int>(globalRow), static_cast<int>(globalCol)) == true) {
        sharedTemperatures[localRow + 1][localCol + 1] = cellsIn[globalIndex];
    } else {
        sharedTemperatures[localRow + 1][localCol + 1] = 0.0f;
    }



    __syncthreads();

}