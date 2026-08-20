//
// Created by elder on 8/19/2026.
//

#ifndef CUDAPRACTICE_DEVICEFUNCTIONS_CUH
#define CUDAPRACTICE_DEVICEFUNCTIONS_CUH

constexpr float DX = 1;
constexpr float DY = 1;
constexpr float DT = 0.1;

constexpr int CELL_SIZE_W = 10;
constexpr int CELL_SIZE_H = 10;

constexpr int CELL_ROW = CELL_SIZE_H / 2;
constexpr int CELL_COL = CELL_SIZE_W / 2;

constexpr int TOTAL_CELLS = CELL_SIZE_W * CELL_SIZE_H;
constexpr int CENTER_CELL = CELL_ROW * CELL_SIZE_W + CELL_COL;

constexpr int TPB = 16;

inline int directions [4][2] = {
    {-1, 0,},{1, 0}, // left, right
    {0, -1}, {0, 1} // down, up
};

__global__ void calculateCellTemp(int *cells);

__device__ bool validCell(int row, int col);


#endif //CUDAPRACTICE_DEVICEFUNCTIONS_CUH