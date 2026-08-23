//
// Created by elder on 8/21/2026.
//

#ifndef CUDAPRACTICE_DEVICEFUNCTIONS_CUH
#define CUDAPRACTICE_DEVICEFUNCTIONS_CUH
#include "glad/glad.h"

constexpr float DX = 12.5f;
constexpr float DY = 5.0f;
constexpr float DT = 2.0f;

constexpr int CELL_SIZE_W = 800;
constexpr int CELL_SIZE_H = 800;

constexpr int CELL_ROW = CELL_SIZE_H / 2;
constexpr int CELL_COL = CELL_SIZE_W / 2;

constexpr int TOTAL_CELLS = CELL_SIZE_W * CELL_SIZE_H;
constexpr int CENTER_CELL = CELL_ROW * CELL_SIZE_W + CELL_COL;

constexpr int TPB = 16;

__device__ bool kernelValidCell(int row, int col);

__global__ void kernelCalculateCellTemp(float *cellsIn, float *cellsOut);

__global__ void kernelChangeCellColor(float *cellsIn, const float3 *colors, float3 *colorsOut);

#endif //CUDAPRACTICE_DEVICEFUNCTIONS_CUH