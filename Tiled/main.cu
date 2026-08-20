//
// Created by elder on 8/20/2026.
//

#include <iostream>
#include "deviceFunctions.cuh"

int main() {
    float *hostCells = static_cast<float *>(calloc(TOTAL_CELLS, sizeof(float)));


    dim3 threads(TPB, TPB);
    auto blocksX = (CELL_SIZE_W + threads.x - 1) / threads.x;
    auto blocksY = (CELL_SIZE_H + threads.y - 1) / threads.y;
    dim3 blocks(blocksX, blocksY);


    return 0;
}