//
// Created by elder on 8/21/2026.
//

#include <iostream>

#include "../Header/deviceFunctions.cuh"
#include "../Header/glUtils.cuh"

int main() {
    if (!glfwInit()) {
        printf("FAILED TO LOAD GLFW\n");
        exit(EXIT_FAILURE);
    }

    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    GLFWwindow *window = createWindow(800, 800, "Heat Diffusion");
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

    float *hostCells = static_cast<float *>(calloc(TOTAL_CELLS, sizeof(float)));
    if (hostCells == nullptr) {
        printf("FAILED TO ALLOCATE MEMORY FOR HOST_CELLS\n");
        exit(EXIT_FAILURE);
    }

    for (int i = 0; i < TOTAL_CELLS; i++) {
        hostCells[i] = 20.0f;
    }

    hostCells[CENTER_CELL] = 100.0f;

    float *deviceCellsIn = nullptr;
    float *deviceCellsOut = nullptr;
    cudaError err = {};

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

    err = cudaMemcpy(deviceCellsIn, hostCells, TOTAL_CELLS * sizeof(float), cudaMemcpyHostToDevice);
    if (err != cudaSuccess) {
        printf("FAILED TO COPY DATA FOR DEVICE_CELLS_IN\n");
        exit(EXIT_FAILURE);
    }

    while (!glfwWindowShouldClose(window)) {
        glClear(GL_COLOR_BUFFER_BIT);

        glfwPollEvents();
        glfwSwapBuffers(window);
    }
}