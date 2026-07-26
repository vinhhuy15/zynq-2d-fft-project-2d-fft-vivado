CXX ?= g++
CXXFLAGS ?= -std=c++17 -O2 -Wall -Wextra -Iinclude

SRC = src/fft2d_fixed.cpp tb/testbench.cpp
TARGET = build/fft2d_fixed_tb

all: $(TARGET)

$(TARGET): $(SRC) include/fft2d_fixed.hpp
	mkdir -p build
	$(CXX) $(CXXFLAGS) $(SRC) -o $(TARGET)

run-square-64: all
	./$(TARGET) \
		../../software/python_reference/zynq_2d_fft_python_reference/data/input/square_64x64_r_matrix_2d.txt \
		../../software/python_reference/zynq_2d_fft_python_reference/data/input/square_64x64_g_matrix_2d.txt \
		../../software/python_reference/zynq_2d_fft_python_reference/data/input/square_64x64_b_matrix_2d.txt \
		../../software/python_reference/zynq_2d_fft_python_reference/data/reference/square_64x64_r_fft_real_2d.txt \
		../../software/python_reference/zynq_2d_fft_python_reference/data/reference/square_64x64_g_fft_real_2d.txt \
		../../software/python_reference/zynq_2d_fft_python_reference/data/reference/square_64x64_b_fft_real_2d.txt \
		../../software/python_reference/zynq_2d_fft_python_reference/data/reference/square_64x64_r_fft_imag_2d.txt \
		../../software/python_reference/zynq_2d_fft_python_reference/data/reference/square_64x64_g_fft_imag_2d.txt \
		../../software/python_reference/zynq_2d_fft_python_reference/data/reference/square_64x64_b_fft_imag_2d.txt \
		square_64x64_r_hls_prep_fft_real_2d.txt \
		square_64x64_g_hls_prep_fft_real_2d.txt \
		square_64x64_b_hls_prep_fft_real_2d.txt \
		square_64x64_r_hls_prep_fft_imag_2d.txt \
		square_64x64_g_hls_prep_fft_imag_2d.txt \
		square_64x64_b_hls_prep_fft_imag_2d.txt

run-all-64: all
	mkdir -p results/portable build/portable-output
	printf "sample,channel,width,height,real_mae,real_mse,real_rmse,real_max_abs,imag_mae,imag_mse,imag_rmse,imag_max_abs,status\n" > results/portable/hls_prep_color_accuracy_64x64.csv
	for sample in square gradient checker circle; do \
		echo "Running $$sample 64x64..."; \
		output=$$(./$(TARGET) \
			../../software/python_reference/zynq_2d_fft_python_reference/data/input/$${sample}_64x64_r_matrix_2d.txt \
			../../software/python_reference/zynq_2d_fft_python_reference/data/input/$${sample}_64x64_g_matrix_2d.txt \
			../../software/python_reference/zynq_2d_fft_python_reference/data/input/$${sample}_64x64_b_matrix_2d.txt \
			../../software/python_reference/zynq_2d_fft_python_reference/data/reference/$${sample}_64x64_r_fft_real_2d.txt \
			../../software/python_reference/zynq_2d_fft_python_reference/data/reference/$${sample}_64x64_g_fft_real_2d.txt \
			../../software/python_reference/zynq_2d_fft_python_reference/data/reference/$${sample}_64x64_b_fft_real_2d.txt \
			../../software/python_reference/zynq_2d_fft_python_reference/data/reference/$${sample}_64x64_r_fft_imag_2d.txt \
			../../software/python_reference/zynq_2d_fft_python_reference/data/reference/$${sample}_64x64_g_fft_imag_2d.txt \
			../../software/python_reference/zynq_2d_fft_python_reference/data/reference/$${sample}_64x64_b_fft_imag_2d.txt \
			build/portable-output/$${sample}_64x64_r_hls_prep_fft_real_2d.txt \
			build/portable-output/$${sample}_64x64_g_hls_prep_fft_real_2d.txt \
			build/portable-output/$${sample}_64x64_b_hls_prep_fft_real_2d.txt \
			build/portable-output/$${sample}_64x64_r_hls_prep_fft_imag_2d.txt \
			build/portable-output/$${sample}_64x64_g_hls_prep_fft_imag_2d.txt \
			build/portable-output/$${sample}_64x64_b_hls_prep_fft_imag_2d.txt); \
		status=$$?; \
		echo "$$output"; \
		if [ $$status -eq 0 ]; then result=PASS; else result=FAIL; fi; \
		for channel in r g b; do \
			real_metrics=$$(echo "$$output" | awk -v ch=$$channel -F '[:, ]+' '$$1=="Channel" && $$2==ch && $$3=="Real" {print $$5","$$7","$$9","$$11}'); \
			imag_metrics=$$(echo "$$output" | awk -v ch=$$channel -F '[:, ]+' '$$1=="Channel" && $$2==ch && $$3=="Imag" {print $$5","$$7","$$9","$$11}'); \
			echo "$$sample,$$channel,64,64,$$real_metrics,$$imag_metrics,$$result" >> results/portable/hls_prep_color_accuracy_64x64.csv; \
		done; \
		if [ $$status -ne 0 ]; then exit $$status; fi; \
	done

clean:
	rm -rf build results/portable
