//
// Created by elder on 8/19/2026.
//

#include "deviceFunctions.cuh"

__device__ bool kernelValidCell(const int row, const int col) {
    if (row < 0 || row >= TOTAL_CELLS || col < 0 || col >= TOTAL_CELLS) return false;
    return true;
}

__global__ void kernelCalculateCellTemp(float *cellsIn, float *cellsOut) {
    unsigned int col = blockIdx.x * blockDim.x + threadIdx.x;
    unsigned int row = blockIdx.y * blockDim.y + threadIdx.y;
    int globalIndex = static_cast<int>(row) * CELL_SIZE_W + static_cast<int>(col);

    if (kernelValidCell(static_cast<int>(row), static_cast<int>(col)) == false) return;
    if (globalIndex >= TOTAL_CELLS) return;

    int directions [4][2] = {
        {-1, 0,},{1, 0}, // left, right
        {0, -1}, {0, 1} // down, up
    };

    int neighborCount = 0;
    int neighborCells[4] = {0};
    int index = 0;
    for (auto &direction : directions) {
        const int x = static_cast<int>(row) + direction[0];
        const int y = static_cast<int>(row) + direction[1];

        if (kernelValidCell(x, y) == false) continue;

        int neighborCellGlobalIndex = x * CELL_SIZE_W + col;
        neighborCells[index++] = neighborCellGlobalIndex;
        neighborCount++;
    }

    if (neighborCount == 4) {
        float xAxisPartialSum = DT * (cellsIn[neighborCells[0]] - (2*cellsIn[globalIndex]) + cellsIn[neighborCells[1]]);
        float yAxisPartialSum = DT * (cellsIn[neighborCells[2]] - (2*cellsIn[globalIndex]) + cellsIn[neighborCells[3]]);

        float xAxisFinalSum= xAxisPartialSum / (DX * DX);
        float yAxisFinalSum= yAxisPartialSum / (DY * DY);

        float finalSum = cellsIn[globalIndex] + xAxisFinalSum + yAxisFinalSum;

        cellsOut[globalIndex] = finalSum;
    } else {
        cellsOut[globalIndex] = cellsIn[globalIndex];
    }
}