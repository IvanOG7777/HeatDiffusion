cmake_minimum_required(VERSION 3.28)
project(CudaPractice LANGUAGES C CXX CUDA)

set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_CUDA_STANDARD 20)
set(CMAKE_CUDA_STANDARD_REQUIRED ON)

set(CMAKE_CUDA_ARCHITECTURES 86)

add_executable(HostHeatDiffusion
        main.cpp
)

add_executable(HeatDiffusionNaive
        Naive/main.cu
        Naive/deviceFunctions.cu
        Naive/deviceFunctions.cuh
)

add_executable(DeviceHeatDiffusionTiled
        Tiled/main.cu
        Tiled/deviceFunctions.cu
        Tiled/deviceFunctions.cuh
)

add_executable(VisualHeatDiffusion
        Visual/Source/main.cu

        Visual/Header/deviceFunctions.cu
        Visual/Header/deviceFunctions.cuh
)