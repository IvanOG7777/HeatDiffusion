//
// Created by elder on 8/20/2026.
//

#include <assert.h>
#include <iostream>
#include "deviceFunctions.cuh"

int main() {
    float *hostCells = static_cast<float *>(calloc(TOTAL_CELLS, sizeof(float)));
    assert(hostCells != nullptr);

    for (int i = 0; i < TOTAL_CELLS; i++) {
        hostCells[i] = 20.0f;
    }

    hostCells[CENTER_CELL] = 100.0f;

    float *deviceCellsIn = nullptr;
    float *deviceCellsOut = nullptr;
    cudaError err = {};

    err = cudaMalloc(&deviceCellsIn, TOTAL_CELLS * sizeof(float));
    if (err != cudaSuccess) {
        printf("FAILED TO ALLOCATE MEMORY FOR DEVICE_CELLS_IN\n");
        exit(EXIT_FAILURE);
    }

    err = cudaMalloc(&deviceCellsOut, TOTAL_CELLS * sizeof(float));
    if (err != cudaSuccess) {
        printf("FAILED TO ALLOCATE MEMORY FOR DEVICE_CELLS_OUT\n");
        exit(EXIT_FAILURE);
    }

    err = cudaMemcpy(deviceCellsIn, hostCells, TOTAL_CELLS * sizeof(float), cudaMemcpyHostToDevice);
    if (err != cudaSuccess) {
        printf("FAILED TO COPY MEMORY FOR DEVICE_CELLS_IN\n");
        exit(EXIT_FAILURE);
    }

    dim3 threads(TPB, TPB);
    auto blocksX = (CELL_SIZE_W + threads.x - 1) / threads.x;
    auto blocksY = (CELL_SIZE_H + threads.y - 1) / threads.y;
    dim3 blocks(blocksX, blocksY);

    kernelCalculateCellTemp<<<blocks, threads>>>(deviceCellsIn, deviceCellsOut);


    return 0;
}