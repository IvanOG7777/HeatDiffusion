//
// Created by elder on 8/18/2026.
//

#include <iostream>

constexpr float DX = 1;
constexpr float DY = 1;
constexpr float DT = 0.1;
constexpr int CELL_SIZE_W = 5;
constexpr int CELL_SIZE_H = 5;

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
                int y = row  + direction[1];

                if (checkValidCell(x, y) == false) continue;

                int innerFlatIndex = x * CELL_SIZE_W + y;
                neighborCount++;
                neighborCells[index++] = innerFlatIndex;
            }
            neighborCellCount[flatIndex] = neighborCount;
            if (neighborCount == 4) {
                float xAxisPartialSum = DT * (cells[neighborCells[0]] - (2*cells[flatIndex]) + cells[neighborCells[1]]);
                float yAxisPartialSum = DT * (cells[neighborCells[1]] - (2*cells[flatIndex]) + cells[neighborCells[3]]);

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
    float *cells = static_cast<float *>(calloc(CELL_SIZE_W * CELL_SIZE_H, sizeof(float)));

    for (int i = 0 ; i < CELL_SIZE_W * CELL_SIZE_H;  i++) {
        cells[i] = 20.0f;
    }

    std:: cout << CELL_SIZE_W * CELL_SIZE_H << std:: endl;
    std:: cout << (CELL_SIZE_W * CELL_SIZE_H) / 2 << std:: endl;

    cells[(CELL_SIZE_W * CELL_SIZE_H)/2] = 100.0f;

    for (int row = 0; row < CELL_SIZE_H; row++) {
        for (int col = 0; col < CELL_SIZE_W; col++) {
            int flatIndex = row * CELL_SIZE_W + col;

            std:: cout << cells[flatIndex] << " ";
        }
        std:: cout << std:: endl;
    }
    std:: cout << std:: endl;

    calculateNewTemp(cells);

    for (int row = 0; row < CELL_SIZE_H; row++) {
        for (int col = 0; col < CELL_SIZE_W; col++) {
            int flatIndex = row * CELL_SIZE_W + col;

            std:: cout << cells[flatIndex] << " ";
        }
        std:: cout << std:: endl;
    }
    std:: cout << std:: endl;

    free(cells);

    return 0;
}