@echo off
if not exist build mkdir build
if not exist output mkdir output

g++ -std=c++17 -O2 -Wall -Wextra -Iinclude src/main.cpp src/fft2d_reference.cpp -o build\fft2d_reference.exe

if errorlevel 1 (
    echo Build failed.
    exit /b 1
)

build\fft2d_reference.exe 64 64 ../../data/input/square_64x64_matrix_2d.txt output/square_64x64 ../../data/reference/square_64x64_fft_real_2d.txt ../../data/reference/square_64x64_fft_imag_2d.txt
