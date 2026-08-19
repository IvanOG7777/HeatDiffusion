//
// Created by elder on 8/18/2026.
//

#include <iostream>

constexpr float DX = 1;
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
    for (int row = 0; row < CELL_SIZE_H; row++) {
        for (int col = 0; col < CELL_SIZE_W; col++) {
            int flatIndex = row * CELL_SIZE_W + col;

            for (auto &direction : directions) {
                int x = row  + direction[0];
                int y = row  + direction[1];

                if (checkValidCell(x, y) == false) continue;

                int innerFlatIndex = x * CELL_SIZE_W + col;

                float partialNewTemp = cells[innerFlatIndex] + DT * (cells[flatIndex - 1] - 2*cells[flatIndex] + cells[flatIndex + 1]);
                float newTemp = partialNewTemp / (DX * DX);
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

    free(cells);

    return 0;
}