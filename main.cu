//
// Created by elder on 8/18/2026.
//

#include <iostream>
#include "deviceFunctions.cuh"
constexpr int blockX =  (CELL_SIZE_W + TPB - 1) / TPB;
int main() {

    float *hostCells = static_cast<float *>(calloc(TOTAL_CELLS, sizeof(float)));

    for (int i = 0; i < TOTAL_CELLS; i++) {
        hostCells[i] = 20.0f;
    }
    hostCells[CENTER_CELL] = 100.0f;

    float *deviceCellsIn = nullptr;
    float *deviceCellsOut = nullptr;
    cudaError err = {};

    err = cudaMalloc(&deviceCellsIn, TOTAL_CELLS * sizeof(float));
    if (err != cudaSuccess) {
        printf("FAILED TO ALLOCATE MEMORY FOR DEVICE_CELLS_IN");
        exit(EXIT_FAILURE);
    }

    err = cudaMalloc(&deviceCellsOut, TOTAL_CELLS * sizeof(float));
    if (err != cudaSuccess) {
        printf("FAILED TO ALLOCATE MEMORY FOR DEVICE_CELLS_OUT");
        exit(EXIT_FAILURE);
    }

    err = cudaMemcpy(deviceCellsIn, hostCells, TOTAL_CELLS * sizeof(float), cudaMemcpyHostToDevice);
    if (err != cudaSuccess) {
        printf("FAILED TO COPY MEMORY FOR DEVICE_CELLS_IN");
        exit(EXIT_FAILURE);
    }

    dim3 threads(TPB, TPB);
    dim3 blocks((CELL_SIZE_W + TPB - 1) / TPB, (CELL_SIZE_H + TPB - 1) / TPB);

    for (int i = 0; i < 10; i ++) {

        printf("Step: %d\n", i);
        for (int row = 0; row < CELL_SIZE_H; row++) {
            for (int col = 0; col < CELL_SIZE_W; col++) {
                int flatIndex = row * CELL_SIZE_W + col;

                printf("%.2f ", hostCells[flatIndex]);
            }
            printf("\n");
        }
        printf("\n");

        kernelCalculateCellTemp<<<blocks, threads>>>(deviceCellsIn, deviceCellsOut);
        cudaDeviceSynchronize();

        err = cudaMemcpy(hostCells, deviceCellsOut, TOTAL_CELLS * sizeof(float), cudaMemcpyDeviceToHost);
        if (err != cudaSuccess) {
            printf("FAILED TO COPY MEMORY FOR HOST_CELLS");
            exit(EXIT_FAILURE);
        }

        float *tempPointer = deviceCellsIn;
        deviceCellsIn = deviceCellsOut;
        deviceCellsOut = tempPointer;
    }

    free(hostCells);
    cudaFree(deviceCellsIn);
    cudaFree(deviceCellsOut);

    return 0;
}