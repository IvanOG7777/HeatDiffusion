//
// Created by elder on 8/18/2026.
//

#include <iostream>

constexpr float DX = 1;
constexpr float DY = 1;
constexpr float DT = 0.1;

constexpr int CELL_SIZE_W = 10;
constexpr int CELL_SIZE_H = 10;

constexpr int CELL_ROW = CELL_SIZE_H / 2;
constexpr int CELL_COL = CELL_SIZE_W / 2;

constexpr int TOTAL_CELLS = CELL_SIZE_W * CELL_SIZE_H;
constexpr int CENTER_CELL = CELL_ROW * CELL_SIZE_W + CELL_COL;

int directions [4][2] = {
    {-1, 0,},{1, 0}, // left, right
    {0, -1}, {0, 1} // down, up
};

bool checkValidCell(int row, int col) {
    if (row < 0 || row >= CELL_SIZE_H || col < 0 || col >= CELL_SIZE_W) return false;
    return true;
}

void calculateNewTemp(float *cells) {
    float newCells[CELL_SIZE_H * CELL_SIZE_W] = {};
    int neighborCellCount[CELL_SIZE_H * CELL_SIZE_W] = {};
    for (int row = 0; row < CELL_SIZE_H; row++) {
        for (int col = 0; col < CELL_SIZE_W; col++) {
            int flatIndex = row * CELL_SIZE_W + col;
            int neighborCount = 0;
            int neighborCells[4] = {0};
            int index = 0;
            for (auto &direction : directions) {
                int x = row  + direction[0];
                int y = col  + direction[1];

                if (checkValidCell(x, y) == false) continue;

                int innerFlatIndex = x * CELL_SIZE_W + y;
                neighborCount++;
                neighborCells[index++] = innerFlatIndex;
            }
            neighborCellCount[flatIndex] = neighborCount;
            if (neighborCount == 4) {
                float xAxisPartialSum = DT * (cells[neighborCells[0]] - (2*cells[flatIndex]) + cells[neighborCells[1]]);
                float yAxisPartialSum = DT * (cells[neighborCells[2]] - (2*cells[flatIndex]) + cells[neighborCells[3]]);

                float xAxisFinalSum = xAxisPartialSum / (DX * DX);
                float yAxisFinalSum = yAxisPartialSum / (DY * DY);

                float finalSum = cells[flatIndex] + xAxisFinalSum + yAxisFinalSum;

                newCells[flatIndex] = finalSum;
            }
        }
    }

    for (int row = 0; row < CELL_SIZE_H; row++) {
        for (int col = 0; col < CELL_SIZE_W; col++) {
            int flatIndex = row * CELL_SIZE_W + col;

            if (neighborCellCount[flatIndex] == 4) {
                cells[flatIndex] = newCells[flatIndex];
            }
        }
    }
}

int main() {
    float *cells = static_cast<float *>(calloc(TOTAL_CELLS, sizeof(float)));

    for (int i = 0 ; i < TOTAL_CELLS;  i++) {
        cells[i] = 20.0f;
    }

    cells[CENTER_CELL] = 100.0f;

    for (int i = 0; i < 10; i++) {
        if (cells[CENTER_CELL] <= 20.001f) break;

        std:: cout << "Step: " << i + 1 << std:: endl;
        for (int row = 0; row < CELL_SIZE_H; row++) {
            for (int col = 0; col < CELL_SIZE_W; col++) {
                int flatIndex = row * CELL_SIZE_W + col;

                printf("%.2f ", cells[flatIndex]);
            }
            std:: cout << std:: endl;
        }
        std:: cout << std:: endl;

        calculateNewTemp(cells);
    }

    free(cells);

    return 0;
}