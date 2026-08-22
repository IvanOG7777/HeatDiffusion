//
// Created by elder on 8/22/2026.
//

#include "../Header/glUtils.cuh"
#include "../Header/deviceFunctions.cuh"

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
    return R"GLSL(
    #version 330 core

    layout (location = 0) in vec2 aPos;
    layout (location = 1) in vec3 aColor;

    out vec3 vertexColor;

    void main() {
        gl_Position = vec4(aPos, 0.0, 1.0);
        gl_PointSize = 2.0;
        vertexColor = aColor;
    }
    )GLSL";
}


const char *makeFragmentShader() {
    return R"GLSL(
    #version 330 core

    in vertexColor;
    out vec4 FragColor;

    void main() {
        FragColor = vec4(vertexColor, 1,0);
    }
    )GLSL";
}

void setVAO(GLuint VAO, GLuint positionVBO, GLuint colorVBO, GLenum drawHint) {
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &positionVBO);
    glGenBuffers(1, &colorVBO);

    glBindVertexArray(VAO);

    glBindBuffer(GL_ARRAY_BUFFER, positionVBO);
    glBufferData(GL_ARRAY_BUFFER, TOTAL_CELLS * 2 * sizeof(float), nullptr, drawHint);
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, sizeof(float), static_cast<void *>(nullptr));
    glEnableVertexAttribArray(0);

    glBindBuffer(GL_ARRAY_BUFFER, colorVBO);
    glBufferData(GL_ARRAY_BUFFER, TOTAL_CELLS * 3 * sizeof(float), nullptr, drawHint);
    glVertexAttribPointer(0,3, GL_FLOAT, GL_FALSE, sizeof(float), static_cast<void *>(nullptr));
    glEnableVertexAttribArray(0);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
}

GLuint compileShader(const char *shader, GLenum shaderType) {
    GLuint s = glCreateShader(shaderType);
    glShaderSource(s, 1, &shader, nullptr);
    glCompileShader(s);

    return s;
}