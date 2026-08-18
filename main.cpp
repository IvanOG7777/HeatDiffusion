//
// Created by elder on 8/18/2026.
//

#include <iostream>

constexpr float DX = 1;
constexpr float DT = 0.1;
constexpr int CELL_SIZE = 20;

void calculateNewTemp(float *cells) {
    float newCells[CELL_SIZE] = {};
    for (int i = 0; i < CELL_SIZE; i++) {
        if (i == 0 || i == CELL_SIZE-1) continue;
        float partialNewTemp = cells[i] + DT  * (cells[i - 1] - 2*cells[i] + cells[i + 1]);

        float newTemp = partialNewTemp / (DX * DX);

        newCells[i] = newTemp;
    }

    for (int i = 0; i < CELL_SIZE; i++) {
        if (i == 0 || i == CELL_SIZE - 1) continue;
        cells[i] = newCells[i];
    }
}

int main() {
    float *cells = static_cast<float *>(calloc(CELL_SIZE, sizeof(float)));

    for (int i = 0 ; i < CELL_SIZE;  i++) {
        cells[i] = 20.0f;
    }

    cells[CELL_SIZE/2] = 100.0f;

    for (int i = 0; i < CELL_SIZE; i++) {
        printf("%.2f ", cells[i]);
    }
    std:: cout << std:: endl;

    for (int i = 0; i < 1000; i++) {
        if (cells[CELL_SIZE / 2] <= 20.0f) break;
        calculateNewTemp(cells);

        for (int i = 0; i < CELL_SIZE; i++) {
            printf("%.2f ", cells[i]);
        }
        std:: cout << std:: endl;
    }

    free(cells);

    return 0;
}