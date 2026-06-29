CXX ?= g++
CXXFLAGS ?= -std=c++17 -O2 -Wall -Wextra -Iinclude

SRC = src/main.cpp src/fft2d_reference.cpp
TARGET = build/fft2d_reference

all: $(TARGET)

$(TARGET): $(SRC) include/fft2d_reference.hpp
	mkdir -p build output
	$(CXX) $(CXXFLAGS) $(SRC) -o $(TARGET)

run-square-64: all
	./$(TARGET) 64 64 ../../data/input/square_64x64_matrix_2d.txt output/square_64x64 ../../data/reference/square_64x64_fft_real_2d.txt ../../data/reference/square_64x64_fft_imag_2d.txt

run-gradient-64: all
	./$(TARGET) 64 64 ../../data/input/gradient_64x64_matrix_2d.txt output/gradient_64x64 ../../data/reference/gradient_64x64_fft_real_2d.txt ../../data/reference/gradient_64x64_fft_imag_2d.txt

run-checker-64: all
	./$(TARGET) 64 64 ../../data/input/checker_64x64_matrix_2d.txt output/checker_64x64 ../../data/reference/checker_64x64_fft_real_2d.txt ../../data/reference/checker_64x64_fft_imag_2d.txt

run-circle-64: all
	./$(TARGET) 64 64 ../../data/input/circle_64x64_matrix_2d.txt output/circle_64x64 ../../data/reference/circle_64x64_fft_real_2d.txt ../../data/reference/circle_64x64_fft_imag_2d.txt

clean:
	rm -rf build output/*.txt
