//
// Created by elder on 8/18/2026.
//

#include <iostream>

constexpr float DX = 1;
constexpr float DT = 0.016;
constexpr int CELL_SIZE = 20;

void calculateNewTemp(float *cells) {
    float newCells[CELL_SIZE] = {};
    for (int i = 0; i < CELL_SIZE; i++) {
        if (i == 0 || i == CELL_SIZE-1) continue;
        float newTemp = cells[i] + 0.1f  * (cells[i - 1] - 2*cells[i] + cells[i + 1]);

        newCells[i] = newTemp;
    }

    for (int i = 0; i < CELL_SIZE; i++) {
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
        std:: cout << cells[i] << " ";
    }
    std:: cout << std:: endl;

    for (int i = 0; i < 1000; i++) {
        calculateNewTemp(cells);

        for (int i = 0; i < CELL_SIZE; i++) {
            printf("%.2f ", cells[i]);
        }
        std:: cout << std:: endl;
    }


    free(cells);

    return 0;
}