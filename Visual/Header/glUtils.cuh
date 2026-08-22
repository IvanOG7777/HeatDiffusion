//
// Created by elder on 8/22/2026.
//

#ifndef CUDAPRACTICE_GLUTILS_CUH
#define CUDAPRACTICE_GLUTILS_CUH

#include <glad/glad.h>
#include <GLFW/glfw3.h>

GLFWwindow *createWindow(int w, int h, const char *title);

const char *makeVertexShader();
const char *makeFragmentShader();

void setVAO(GLuint VAO, GLuint positionVBO, GLuint colorVBO, GLenum drawHint);

GLuint compileShader(const char *shader, GLenum shaderType);

#endif //CUDAPRACTICE_GLUTILS_CUH