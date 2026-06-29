# Project Handoff Summary — Zynq-7000 2D FFT FPGA Accelerator

This file summarizes the full context of the current ChatGPT conversation so another agent can continue the project without needing to reread the whole chat.

---

## 1. User Goal

The user is working on a **paper/project using a Zynq-7000 board** related to **2D FFT acceleration on FPGA**.

The uploaded reference project/report is:

```text
FPGA-Based Real-Time Video 2D FFT Accelerator.pdf
```

The user wants to complete a paper/project based on this idea, but in a practical and achievable way.

The core task is:

```text
Build or plan a 2D FFT accelerator on Zynq-7000 FPGA, verify it against Python/C++ reference results, then use the implementation/results to write a paper.
```

---

## 2. Source Project Summary

The uploaded PDF describes a Cornell MEng design project titled:

```text
FPGA-Based Real-Time Video 2D FFT Accelerator
```

Main idea of the source project:

```text
Camera/image input → 2D FFT → FPGA acceleration on Zynq Z7010 → output frequency-domain image
```

The report used:

- Zynq Z7010 / Zybo-style board.
- Vitis HLS to convert C++ FFT code to RTL/IP.
- Vivado to integrate the IP onto FPGA.
- MATLAB/Python/C++ to verify FFT correctness.
- Camera pipeline using Pcam and AXI video flow.
- Real-time video target around 15/30 Hz.

Important observations from the report:

1. The software C++/MATLAB FFT verification worked.
2. The FPGA implementation achieved real-time response but had bugs/noisy output.
3. FPGA output mismatch may come from:
   - camera pipeline distortion,
   - complex HDL structure,
   - fixed-point precision issues,
   - overflow,
   - complex-to-grayscale conversion issues,
   - resource constraints.
4. Full-resolution image processing is too heavy for the small Zynq-7000 device.
5. The report reduced image size heavily, around 64×32 / 128×64 scale, because LUT/BRAM resources were limited.
6. The source project used complex-number FFT output and then converted complex magnitude to grayscale:
   ```cpp
   output_matrix[i][j] = hls::log(1 + hls::abs(hls::sqrt(
       row[i][j].r * row[i][j].r + row[i][j].i * row[i][j].i
   )));
   ```
7. This conversion is dangerous on FPGA because `sqrt`, `log`, fixed-point cast, and normalization can consume many resources and cause bad visual output.

---

## 3. Recommended Scope for This Project

The recommended scope is intentionally smaller and safer than full camera real-time FFT:

```text
Design and evaluate a 2D FFT accelerator on Zynq-7000 for small grayscale images using Vitis HLS.
Verify the FFT output against Python/C++ reference results.
Evaluate accuracy, latency, resource utilization, and fixed-point tradeoffs.
```

Recommended initial constraints:

```text
Input: grayscale image
Image sizes: 32×32 first, then 64×64
Algorithm: radix-2 2D FFT
Platform: Zynq-7000
Tools: Python, C++, Vitis HLS, Vivado, Vitis
Output for evaluation: raw FFT real/imag
Output for visualization: magnitude/log-magnitude image
```

Important recommendation:

```text
Do NOT start with camera real-time pipeline.
Do NOT start with Vivado block design.
Do NOT put sqrt/log/normalize into FPGA in the first version.
```

The safe project order is:

```text
1. Python reference
2. C++ floating-point 2D FFT reference
3. Fixed-point C++ / ap_fixed version
4. Vitis HLS C simulation
5. Vitis HLS RTL co-simulation
6. Export HLS IP
7. Vivado block design
8. Vitis host app with AXI DMA
9. Benchmark and paper writing
10. Optional: camera or HDMI demo
```

---

## 4. Recommended System Architecture

The safest architecture is static-image processing using PS + PL + DMA:

```text
Image matrix in DDR
        ↓
ARM PS prepares input buffer
        ↓
AXI DMA MM2S
        ↓
2D FFT IP in PL
        ↓
AXI DMA S2MM
        ↓
DDR output buffer
        ↓
ARM PS reads output and compares / saves / displays
```

Recommended data movement:

```text
PS DDR → AXI DMA → FFT2D HLS IP → AXI DMA → PS DDR
```

Recommended interfaces:

```text
AXI-Lite: start/control/status
AXI-Stream: image/FFT data input and output
AXI DMA: transfer buffers between DDR and PL
```

Minimal Vivado block design:

```text
ZYNQ7 Processing System
Processor System Reset
AXI Interconnect / SmartConnect
AXI DMA
fft2d_accel HLS IP
```

---

## 5. Important FFT Knowledge

2D FFT is computed by applying 1D FFT twice:

```text
Step 1: FFT across every row
Step 2: FFT across every column
```

Pseudo-flow:

```cpp
for each row:
    fft1d(row)

for each column:
    copy column to temporary buffer
    fft1d(column_buffer)
    copy back to matrix
```

The 1D FFT should be radix-2 Cooley-Tukey FFT:

```text
- input length must be power of two
- use bit-reversal permutation
- use butterfly operation
- use twiddle factors
```

Forward FFT convention should match NumPy:

```text
X[k] = sum_n x[n] * exp(-j * 2πkn / N)
```

Important:

```text
NumPy forward FFT is not normalized.
Inverse FFT divides by N.
```

For 2D inverse FFT, inverse row + inverse column causes normalization by width × height.

---

## 6. Why Fixed-Point Is Hard

The user must be careful with fixed-point format.

For a 64×64 grayscale image, maximum DC term can be:

```text
255 × 64 × 64 = 1,044,480
```

This requires around 20 integer bits just for the largest DC component.

Therefore, formats like:

```cpp
ap_fixed<16,4>
ap_fixed<16,8>
```

are likely too small and can overflow.

Safer initial formats:

```cpp
ap_fixed<32,20>
ap_fixed<32,16>
ap_fixed<24,16>
ap_fixed<24,12>
```

The first fixed-point version should prioritize correctness over low resource usage.

Recommended fixed-point test table:

| Format | Accuracy | Resource | Risk |
|---|---|---|---|
| ap_fixed<32,20> | High | High | Low overflow risk |
| ap_fixed<24,16> | Medium-high | Medium | Reasonable |
| ap_fixed<20,12> | Medium | Lower | More overflow risk |
| ap_fixed<16,10> | Low-medium | Low | High overflow risk |

Important mitigation:

```text
Consider scaling by 1/2 after each FFT stage to avoid overflow.
```

If scaling is used, Python/C++ reference must apply the same scaling before comparison.

---

## 7. Important Design Decision

For the main FPGA/HLS accelerator, output raw FFT real/imag values first:

```text
input grayscale pixels → FFT IP → real/imag FFT output
```

Do not make the first hardware version output only an 8-bit image, because normalization and log-magnitude can hide bugs.

Recommended outputs:

### Main numerical output

```text
real0, imag0, real1, imag1, ...
```

or separate streams/files:

```text
fft_real
fft_imag
```

### Visualization output

Do this later on CPU/Python:

```python
magnitude = abs(real + 1j * imag)
display = log(1 + magnitude)
normalize to 0..255
```

---

## 8. Files Already Generated in This Chat

Two project packages were generated.

### Step 1 — Python Reference

File created:

```text
/mnt/data/zynq_2d_fft_python_reference.zip
```

Contents:

```text
software/python_reference/fft2_reference.py
software/python_reference/compare_fft_outputs.py
data/input/
data/reference/
data/visual/
results/
```

Purpose:

```text
Generate trusted Python NumPy fft2 reference data.
```

Generated sample images:

```text
32×32: square, gradient, checker, circle
64×64: square, gradient, checker, circle
```

Important generated files:

```text
data/input/*_matrix_2d.txt
data/input/*_matrix_flat_row_major.txt

data/reference/*_fft_real_2d.txt
data/reference/*_fft_imag_2d.txt
data/reference/*_fft_real_flat_row_major.txt
data/reference/*_fft_imag_flat_row_major.txt

data/visual/*_fft_log_magnitude_shifted.png
```

Meaning:

```text
*_matrix_2d.txt                  input grayscale matrix
*_matrix_flat_row_major.txt      input flattened for stream/DMA-style testing
*_fft_real_2d.txt                Python NumPy real FFT reference
*_fft_imag_2d.txt                Python NumPy imaginary FFT reference
*_fft_log_magnitude_shifted.png  visual FFT magnitude image
```

Important note:

```text
Raw FFT real/imag files are NOT fftshifted.
The shifted PNG files are only for visualization.
```

Command to regenerate all 64×64 sample references:

```bash
python software/python_reference/fft2_reference.py --sample all --width 64 --height 64 --out .
```

Command to run with a custom image:

```bash
python software/python_reference/fft2_reference.py --image my_image.png --width 64 --height 64 --out .
```

---

### Step 2 — C++ 2D FFT Reference

File created:

```text
/mnt/data/zynq_2d_fft_step2_cpp_reference.zip
```

Contents:

```text
data/input/
data/reference/
data/visual/
software/cpp_reference/
results/
```

Important C++ files:

```text
software/cpp_reference/include/fft2d_reference.hpp
software/cpp_reference/src/fft2d_reference.cpp
software/cpp_reference/src/main.cpp
software/cpp_reference/Makefile
software/cpp_reference/build_and_run_windows.ps1
software/cpp_reference/build_and_run_windows.bat
```

Algorithm implemented:

```text
Iterative radix-2 Cooley-Tukey 1D FFT
2D FFT = row FFT + column FFT
Forward convention matches numpy.fft.fft2()
```

Validated result from chat:

```text
Test: square_64x64
Real MAE: 0.0000000000
Imag MAE: 0.0000000000
MaxAbs: about 1e-10
```

This means the C++ floating-point version matches Python NumPy reference and is ready to become the base for fixed-point/HLS conversion.

Build/run on Windows PowerShell:

```powershell
cd software/cpp_reference
./build_and_run_windows.ps1
```

Manual build/run:

```powershell
g++ -std=c++17 -O2 -Wall -Wextra -Iinclude src/main.cpp src/fft2d_reference.cpp -o build/fft2d_reference.exe

./build/fft2d_reference.exe 64 64 ../../data/input/square_64x64_matrix_2d.txt output/square_64x64 ../../data/reference/square_64x64_fft_real_2d.txt ../../data/reference/square_64x64_fft_imag_2d.txt
```

Build/run on Linux/WSL/MSYS2:

```bash
cd software/cpp_reference
make
make run-square-64
```

---

## 9. What the Next Agent Should Do Next

The next step is:

```text
Step 3: Convert C++ double FFT into fixed-point ap_fixed version for Vitis HLS.
```

Recommended actions:

1. Copy the C++ reference into a new folder:

```text
hls/fixed_point_reference/
```

2. Replace `double` with a typedef that can be changed easily:

```cpp
#include <ap_fixed.h>

typedef ap_fixed<32,20> data_t;
```

3. Modify complex struct:

```cpp
struct ComplexFixed {
    data_t real;
    data_t imag;
};
```

4. Avoid dynamic allocation in HLS version:

Bad for HLS:

```cpp
std::vector<Complex>
```

Better for HLS:

```cpp
static ComplexFixed matrix[HEIGHT][WIDTH];
static ComplexFixed row_buffer[WIDTH];
static ComplexFixed col_buffer[HEIGHT];
```

5. Use compile-time constants first:

```cpp
#define HEIGHT 64
#define WIDTH 64
```

6. Create HLS-compatible top function:

```cpp
void fft2d_fixed_top(
    data_t in_real[HEIGHT][WIDTH],
    data_t out_real[HEIGHT][WIDTH],
    data_t out_imag[HEIGHT][WIDTH]
);
```

7. First run C simulation only:

```text
Input: data/input/square_64x64_matrix_2d.txt
Reference: data/reference/square_64x64_fft_real_2d.txt and fft_imag_2d.txt
Output: fixed-point real/imag
Metrics: MAE, MSE, MaxAbs
```

8. Do not integrate DMA yet.

---

## 10. Vitis HLS Version Strategy

### Version A — easiest HLS C simulation version

Top function:

```cpp
void fft2d_fixed_top(
    pixel_t input[HEIGHT][WIDTH],
    data_t output_real[HEIGHT][WIDTH],
    data_t output_imag[HEIGHT][WIDTH]
);
```

Use this first because arrays are easiest to debug.

### Version B — stream version for Vivado/DMA

After Version A works, create AXI Stream top:

```cpp
void fft2d_accel(
    hls::stream<axis_t>& in_stream,
    hls::stream<axis_t>& out_stream
);
```

Suggested HLS interface pragmas:

```cpp
#pragma HLS INTERFACE axis port=in_stream
#pragma HLS INTERFACE axis port=out_stream
#pragma HLS INTERFACE s_axilite port=return bundle=CTRL
```

Recommended output stream format:

```text
real0
imag0
real1
imag1
...
```

or packed:

```text
real and imag in one wider word if practical
```

---

## 11. HLS Optimization Guidance

Do not optimize before correctness.

Correct order:

```text
1. C simulation correct
2. C/RTL co-simulation correct
3. Then optimize
```

Useful optimizations:

### Pipeline loops

```cpp
#pragma HLS PIPELINE II=1
```

Useful on read/write loops and some butterfly loops.

### Array partition

```cpp
#pragma HLS ARRAY_PARTITION variable=row_buffer cyclic factor=2
```

Use carefully. Too much partitioning increases LUT/FF.

### Twiddle lookup table

Avoid runtime `sin()` and `cos()` in hardware. Use precomputed twiddle LUT:

```cpp
twiddle_real[k]
twiddle_imag[k]
```

### Avoid sqrt/log first

Do not put these in the first HLS version:

```cpp
hls::sqrt
hls::log
```

Use raw real/imag output first.

### BRAM guidance

Large matrices should be mapped to BRAM if possible:

```cpp
#pragma HLS BIND_STORAGE variable=matrix type=ram_2p impl=bram
```

Exact pragma may depend on Vitis HLS version.

---

## 12. Paper Structure Recommendation

Recommended paper outline:

```text
Abstract
1. Introduction
2. Background
   2.1 DFT and FFT
   2.2 Radix-2 Cooley-Tukey FFT
   2.3 2D FFT for image processing
   2.4 Zynq-7000 PS/PL architecture
   2.5 Fixed-point arithmetic on FPGA
3. Proposed Architecture
   3.1 Software reference flow
   3.2 HLS accelerator architecture
   3.3 AXI DMA integration
4. Implementation
   4.1 Python reference
   4.2 C++ FFT reference
   4.3 Fixed-point conversion
   4.4 HLS design
   4.5 Vivado/Vitis deployment
5. Experimental Setup
   Board, tools, image sizes, metrics
6. Results
   Accuracy, latency, resource utilization
7. Discussion
   Fixed-point tradeoffs, resource limits, overflow, future camera pipeline
8. Conclusion
```

Important figures to include:

```text
Figure 1: Overall system architecture
Figure 2: 2D FFT flow: row FFT + column FFT
Figure 3: Python/C++/HLS verification flow
Figure 4: Vivado block design
Figure 5: Input image and FFT magnitude output
Figure 6: Fixed-point error comparison
```

Important tables:

```text
Table 1: Accuracy vs Python reference
Table 2: Fixed-point format tradeoff
Table 3: HLS/Vivado resource utilization
Table 4: Latency and speedup comparison
```

---

## 13. Evaluation Metrics

Accuracy metrics:

```text
MAE  = mean absolute error
MSE  = mean squared error
RMSE = root mean squared error
MaxAbs = maximum absolute error
```

Performance metrics:

```text
Latency in ms
Clock cycles
FPS estimate
Speedup over ARM C/C++ baseline
```

Resource metrics:

```text
LUT
FF
BRAM
DSP
Fmax
Timing slack
```

Good baseline:

```text
Compare FPGA against C implementation running on ARM PS.
```

Less fair but still useful:

```text
Compare against Python NumPy on PC only as reference correctness, not as main performance baseline.
```

---

## 14. Common Bugs and How to Debug

### Output all white / all black

Likely causes:

```text
fixed-point overflow
bad normalization
max == min in normalization
bad cast from fixed-point to ap_uint<8>
wrong data range
```

Fix:

```cpp
if (maxElement == minElement) {
    pixel_out = 0;
} else {
    pixel_out = ((value - minElement) * 255) / (maxElement - minElement);
}
```

### FPGA/HLS output differs from Python

Likely causes:

```text
row-major vs column-major mismatch
wrong FFT sign convention
bit-reversal bug
forward FFT accidentally normalized
fixed-point overflow
scaling mismatch
output flattened in different order
```

Debug tests:

```text
1. impulse image
2. all-zero image
3. all-one image
4. single bright pixel
5. compare after row FFT only
6. compare after column FFT
```

### HLS resource too high

Reduce:

```text
image size
bit width
unroll factor
array partitioning
sqrt/log operations
full-frame buffering
```

### DMA problems later

Checklist:

```text
flush cache before sending buffer
invalidate cache after receiving buffer
check buffer alignment
check transfer size
check TLAST
check DMA direction
check AXI stream word width
```

---

## 15. Important Warning About “Compression”

FFT alone is not compression.

FFT only transforms an image from spatial domain to frequency domain.

To claim compression, add this experiment:

```text
1. FFT image
2. Keep only top 5%, 10%, 20% largest coefficients
3. Set remaining coefficients to zero
4. Inverse FFT
5. Compare reconstructed image with original
6. Measure MSE/PSNR
```

Suggested compression table:

| Retained coefficients | Compression ratio | MSE | PSNR | Visual quality |
|---:|---:|---:|---:|---|
| 5% | 20:1 | ... | ... | low |
| 10% | 10:1 | ... | ... | acceptable |
| 20% | 5:1 | ... | ... | good |

This will make the paper stronger if the assignment expects “FFT for image compression”.

---

## 16. Recommended Immediate Next Deliverable

The next agent should create:

```text
zynq_2d_fft_step3_fixed_point_hls_prep.zip
```

Containing:

```text
hls/fixed_point_reference/
  fft2d_fixed.hpp
  fft2d_fixed.cpp
  testbench.cpp
  README.md

results/
  fixed_point_accuracy.csv
```

Minimum success target:

```text
ap_fixed<32,20> 64×64 fixed-point FFT C simulation passes with acceptable error against Python reference.
```

Then test smaller formats:

```text
ap_fixed<24,16>
ap_fixed<24,12>
ap_fixed<20,12>
```

---

## 17. User Preference / Style Notes

The user prefers:

```text
- direct explanations
- detailed but not overly bloated plans
- practical steps
- student-friendly wording
- avoid overly polished/AI-like writing for report content
- clear folder/code structure
- explain why each step matters
```

The user is likely using Windows/PowerShell and has had previous C/C++ environment issues, so provide Windows-friendly commands where possible.

---

## 18. Final One-Line Summary for Next Agent

Continue from the verified C++ floating-point 2D FFT reference and implement the next step: a Vitis-HLS-friendly fixed-point 2D FFT version using `ap_fixed`, starting with 32×32 or 64×64 grayscale matrices and comparing real/imag output against the existing Python NumPy reference files.
