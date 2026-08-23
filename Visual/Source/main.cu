//
// Created by elder on 8/21/2026.
//

#include <iostream>

#include "../Header/deviceFunctions.cuh"
#include "../Header/glUtils.cuh"

#include <cuda_gl_interop.h>

float3 COLORS[8] = {
    {1.0f, 0.0f, 0.0f}, // red
    {1.0f, .23f, 0.0f}, // red orange
    {1.0f, .41f, 0.0f}, // orange
    {1.0f, .60f, 0.0f}, // orange
    {0.0f, .84f, 1.0f}, // teal
    {0.0f, .58f, 1.0f}, // blue
    {0.0f, .35f, 1.0f}, // blue
    {0.0f, 0.0f, 1.0f} // dark blue
};

int main() {
    if (!glfwInit()) {
        printf("FAILED TO LOAD GLFW\n");
        exit(EXIT_FAILURE);
    }

    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    GLFWwindow *window = createWindow(CELL_SIZE_W, CELL_SIZE_H, "Heat Diffusion");
    glfwMakeContextCurrent(window);

    if (!gladLoadGLLoader((GLADloadproc) glfwGetProcAddress)) {
        std::cerr << "GLAD INIT ERROR\n";
        return -1;
    }

    GLuint VAO = 0, positionVBO = 0, colorVBO = 0;

    setVAO(VAO, positionVBO, colorVBO, GL_DYNAMIC_DRAW);

    const char *vertexShader = makeVertexShader();
    const char *fragmentShader = makeFragmentShader();

    GLuint vs = compileShader(vertexShader, GL_VERTEX_SHADER);
    GLuint fs = compileShader(fragmentShader, GL_FRAGMENT_SHADER);

    GLint program = glCreateProgram();
    glAttachShader(program,vs);
    glAttachShader(program,fs);
    glLinkProgram(program);
    glDeleteShader(vs);
    glDeleteShader(fs);

    ////// Host allocations
    float *hostCells = static_cast<float *>(calloc(TOTAL_CELLS, sizeof(float)));
    float *hostCellPositions = static_cast<float *>(calloc(TOTAL_CELLS, 2 * sizeof(float)));
    float3 *hostCellColors = static_cast<float3 *>(calloc(TOTAL_CELLS,  sizeof(float3)));

    if (hostCells == nullptr) {
        printf("FAILED TO ALLOCATE MEMORY FOR HOST_CELLS\n");
        exit(EXIT_FAILURE);
    }
    if (hostCellPositions == nullptr) {
        printf("FAILED TO ALLOCATE MEMORY FOR HOST_CELL_POSITIONS\n");
        exit(EXIT_FAILURE);
    }
    if (hostCellColors == nullptr) {
        printf("FAILED TO ALLOCATE MEMORY FOR HOST_CELL_POSITIONS\n");
        exit(EXIT_FAILURE);
    }
    //////

    ////// Init of cell temps and positions and colors
    for (int i = 0; i < TOTAL_CELLS; i++) {
        hostCells[i] = 20.0f;
    }

    hostCells[CENTER_CELL] = 100.0f;

    for (int row = 0; row < CELL_SIZE_H; row++) {
        for (int col = 0; col < CELL_SIZE_W; col++) {
            int globalIndex = row * CELL_SIZE_W + col;

            float x = (static_cast<float>(col) / (CELL_SIZE_W - 1)) * 2.0f - 1.0f;
            float y = (static_cast<float>(row) / (CELL_SIZE_H - 1)) * 2.0f - 1.0f;

            hostCellPositions[globalIndex * 2 + 0] = x;
            hostCellPositions[globalIndex * 2 + 1] = y;
        }
    }

    for (int i = 0; i < TOTAL_CELLS; i++) {
        hostCellColors[i]= COLORS[7];
    }

    hostCellColors[CENTER_CELL] = COLORS[0];
    //////

    glBindBuffer(GL_ARRAY_BUFFER, positionVBO);
    glBufferSubData(GL_ARRAY_BUFFER,0,TOTAL_CELLS * 2 * sizeof(float), hostCellPositions);
    glBindBuffer(GL_ARRAY_BUFFER, 0);

    glBindBuffer(GL_ARRAY_BUFFER, colorVBO);
    glBufferSubData(GL_ARRAY_BUFFER,0,TOTAL_CELLS * sizeof(float3), hostCellColors);
    glBindBuffer(GL_ARRAY_BUFFER, 0);

    float *deviceCellsIn = nullptr;
    float *deviceCellsOut = nullptr;
    float3 *deviceColors = nullptr;
    cudaError err = {};

    ////// allocations and memory copying
    err = cudaMalloc(&deviceCellsIn, TOTAL_CELLS * sizeof(float));
    if (err != cudaSuccess) {
        printf("FAILED TO ALLOCATE MEMORY FOR DEVICE_CELLS_IN\n");
        exit(EXIT_FAILURE);
    }

    err = cudaMalloc(&deviceCellsOut, TOTAL_CELLS * sizeof(float));
    if (err != cudaSuccess) {
        printf("FAILED TO ALLOCATE MEMORY FOR DEVICE_CELLS_OUT\n");
        exit(EXIT_FAILURE);
    }

    err = cudaMalloc(&deviceColors, 8 * sizeof(float3));
    if (err != cudaSuccess) {
        printf("FAILED TO ALLOCATE MEMORY FOR DEVICE_COLORS\n");
        exit(EXIT_FAILURE);
    }

    err = cudaMemcpy(deviceCellsIn, hostCells, TOTAL_CELLS * sizeof(float), cudaMemcpyHostToDevice);
    if (err != cudaSuccess) {
        printf("FAILED TO COPY DATA FOR DEVICE_CELLS_IN\n");
        exit(EXIT_FAILURE);
    }

    err = cudaMemcpy(deviceColors, COLORS, 8 * sizeof(float3), cudaMemcpyHostToDevice);
    if (err != cudaSuccess) {
        printf("FAILED TO COPY DATA FOR DEVICE_COLORS\n");
        exit(EXIT_FAILURE);
    }
    //////

    cudaGraphicsResource *cudaResource = nullptr;

    err = cudaGraphicsGLRegisterBuffer(&cudaResource, colorVBO, cudaGraphicsMapFlagsWriteDiscard);
    if (err != cudaSuccess) {
        printf("FAILED TO REGISTER COLOR VBO WITH CUDA\n");
        exit(EXIT_FAILURE);
    }

    dim3 threads(TPB, TPB);

    unsigned int blockX = (CELL_SIZE_W + TPB - 1) / TPB; // col
    unsigned int blockY = (CELL_SIZE_H + TPB - 1) / TPB; // row

    dim3 blocks(blockX, blockY);

    // Main render loop
    while (!glfwWindowShouldClose(window)) {
        glClear(GL_COLOR_BUFFER_BIT);

        kernelCalculateCellTemp<<<blocks, threads>>>(deviceCellsIn, deviceCellsOut);
        cudaDeviceSynchronize();

        float3 *deviceVBOColors = nullptr;
        size_t mappedSize = 0;

        cudaGraphicsMapResources(1, &cudaResource);

        cudaGraphicsResourceGetMappedPointer(reinterpret_cast<void **>(&deviceVBOColors),&mappedSize,cudaResource);

        kernelChangeCellColor<<<blocks, threads>>>(deviceCellsOut, deviceColors, deviceVBOColors);
        cudaDeviceSynchronize();

        cudaGraphicsUnmapResources(1, &cudaResource);

        glUseProgram(program);
        glBindVertexArray(VAO);

        glDrawArrays(GL_POINTS, 0, TOTAL_CELLS);

        glBindVertexArray(0);

        std::swap(deviceCellsIn, deviceCellsOut);

        glfwPollEvents();
        glfwSwapBuffers(window);
    }
}