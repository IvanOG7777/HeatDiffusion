//
// Created by elder on 8/22/2026.
//

#include "../Header/glUtils.cuh"

#include <cstdio>

GLFWwindow *createWindow(int w, int h, const char *title) {
    if (w <= 0 || h <= 0) {
        printf("WINDOW ERROR, W OR H IS 0\n");
        exit(EXIT_FAILURE);
    }

    GLFWwindow *window = glfwCreateWindow(w, h, title, nullptr, nullptr);
    if (window == nullptr) {
        printf("WINDOW ERROR, FAILED TO CREATE WINDOW, WINDOW IS NULLPTR\n");
        exit(EXIT_FAILURE);
    }

    return window;
}

const char *makeVertexShader() {
    return "";
}


const char *makeFragmentShader() {
    return ""
}