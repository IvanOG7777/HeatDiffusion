//
// Created by elder on 8/20/2026.
//

#include "deviceFunctions.cuh"

__device__ bool kernelValidCell(int row, int col) {
    if (row < 0 || row >= CELL_SIZE_H || col < 0 || col >= CELL_SIZE_W) return false;
    return true;
}

__global__ void kernelCalculateCellTemp(float *cellsIn, float *cellsOut) {

    unsigned int col = blockIdx.x * blockDim.x + threadIdx.x;
    unsigned int row = blockIdx.y * blockDim.y + threadIdx.y;
    unsigned int globalIndex = row * CELL_SIZE_W + col;
    unsigned int threadCell = threadIdx.x;

    if (kernelValidCell(static_cast<int>(row), static_cast<int>(col)) == false) return;
    if (globalIndex >= TOTAL_CELLS) return;

    __shared__ float sharedTemperatures[TPB] = {0.0f};
    sharedTemperatures[]
}