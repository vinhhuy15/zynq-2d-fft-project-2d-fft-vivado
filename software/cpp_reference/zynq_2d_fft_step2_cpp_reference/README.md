# Zynq 2D FFT - Step 2: C++ Reference

This package contains the second step of the project:

```text
Python NumPy reference -> C++ float/double 2D FFT reference
```

The goal is to confirm that the C++ 2D FFT produces the same output as `numpy.fft.fft2()` before moving to fixed-point and Vitis HLS.

## Folder structure

```text
data/input/                  input grayscale matrices
data/reference/              Python NumPy FFT real/imag reference
data/visual/                 FFT magnitude images for visual checking
software/cpp_reference/       C++ radix-2 2D FFT implementation
results/                     run logs and summaries
```

## Algorithm

2D FFT is computed by:

```text
1. Run 1D FFT across every row.
2. Run 1D FFT across every column.
```

The 1D FFT uses iterative radix-2 Cooley-Tukey FFT with bit-reversal.

Forward FFT convention matches NumPy:

```text
X[k] = sum_n x[n] * exp(-j * 2πkn / N)
```

The forward FFT is not normalized, same as `numpy.fft.fft2()`.

## Build and run on Linux / WSL / MSYS2

```bash
cd software/cpp_reference
make
make run-square-64
```

## Build and run on Windows PowerShell

```powershell
cd software/cpp_reference
./build_and_run_windows.ps1
```

Or manually:

```powershell
g++ -std=c++17 -O2 -Wall -Wextra -Iinclude src/main.cpp src/fft2d_reference.cpp -o build/fft2d_reference.exe

./build/fft2d_reference.exe 64 64 ../../data/input/square_64x64_matrix_2d.txt output/square_64x64 ../../data/reference/square_64x64_fft_real_2d.txt ../../data/reference/square_64x64_fft_imag_2d.txt
```

## Expected result

The error against Python should be extremely small, usually around numerical floating-point noise.

Example:

```text
Comparison with Python NumPy reference:
Real MAE: very small
Imag MAE: very small
```

## Next step

After this is correct, move to:

```text
C++ double FFT -> ap_fixed fixed-point FFT -> Vitis HLS C simulation
```
