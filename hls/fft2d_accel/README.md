# Zynq 2D FFT - Step 3: HLS-Prep FFT Accelerator

This folder is the next project step after the verified Python and C++ references.

The goal is to reshape the working C++ 2D FFT into a Vitis-HLS-friendly top function:

```text
input grayscale matrix -> 2D FFT -> raw real/imag FFT output
```

## What is implemented

- Static `64x64` matrix shape using `FFT2D_HEIGHT` and `FFT2D_WIDTH`.
- HLS-style top function:

```cpp
void fft2d_fixed_top(
    data_t input[FFT2D_HEIGHT][FFT2D_WIDTH],
    data_t output_real[FFT2D_HEIGHT][FFT2D_WIDTH],
    data_t output_imag[FFT2D_HEIGHT][FFT2D_WIDTH]
);
```

- Row FFT followed by column FFT.
- Raw real and imaginary output, not log magnitude.
- Desktop testbench that compares against the Python NumPy reference.
- 64-point twiddle lookup tables for the FFT rotation factors, avoiding runtime `sin/cos` in the HLS datapath.

## Data type

By default, desktop compilation uses:

```cpp
typedef double data_t;
```

For Vitis HLS, compile with `USE_AP_FIXED` so the header uses:

```cpp
typedef ap_fixed<FFT2D_FIXED_TOTAL_BITS, FFT2D_FIXED_INTEGER_BITS, AP_RND, AP_SAT> data_t;
```

If the bit-width macros are not set, the default is `ap_fixed<32,20>`. The selected candidate after the sweep is `ap_fixed<28,20>`.

## Run on Windows PowerShell

From this folder:

```powershell
./build_and_run_windows.ps1
```

The script builds the desktop testbench, runs the 64x64 `square`, `gradient`, `checker`, and `circle` samples, and writes a CSV summary:

```text
results/hls_prep_accuracy_64x64.csv
```

Expected result for the desktop `double` check is near-zero error against the Python reference.

The script also writes per-sample output matrices:

```text
*_64x64_hls_prep_fft_real_2d.txt
*_64x64_hls_prep_fft_imag_2d.txt
```

## Run on Linux / WSL / MSYS2

```bash
make
make run-square-64
make run-all-64
```

## Next HLS tasks

1. Test more input images, not only `square_64x64`.
2. Try smaller fixed-point formats such as `ap_fixed<24,16>` and `ap_fixed<24,12>`.
3. Compare accuracy/resource trade-offs across fixed-point formats.
4. Export the HLS IP and integrate it into a Vivado block design.
5. Create an AXI Stream version later if the project moves to AXI DMA streaming.

## Run Vitis HLS C simulation

On this machine, AMD Vitis 2025.2 uses `vitis-run` instead of the older `vitis_hls` command.

From a normal PowerShell or Command Prompt:

```cmd
cd /d D:\subjects\Thiet_ke_HW_SW\project\zynq-2d-fft\hls\fft2d_accel
call C:\AMDDesignTools\settings64.bat
C:\AMDDesignTools\2025.2\Vitis\bin\vitis-run.bat --mode hls --tcl run_hls_csim.tcl
```

To run C simulation and C synthesis:

```cmd
C:\AMDDesignTools\2025.2\Vitis\bin\vitis-run.bat --mode hls --tcl run_hls_csynth.tcl
```

To run C simulation, C synthesis, and C/RTL co-simulation:

```cmd
C:\AMDDesignTools\2025.2\Vitis\bin\vitis-run.bat --mode hls --tcl run_hls_cosim.tcl
```

The Tcl scripts create `fft2d_accel_prj`, set `fft2d_fixed_top` as the top function, enable `USE_AP_FIXED`, and test against the `square_64x64` Python reference.

To run C/RTL co-simulation for the selected `ap_fixed<28,20>` format on all four 64x64 samples:

```cmd
C:\AMDDesignTools\2025.2\Vitis\bin\vitis-run.bat --mode hls --tcl run_hls_cosim_28_20_64.tcl
```

The result summaries are written to:

```text
results/cosim_28_20_accuracy_64x64.csv
results/cosim_28_20_summary_64x64.csv
```

## Run bit-width sweep

The fixed-point type can be changed from Tcl with:

```text
FFT2D_FIXED_TOTAL_BITS
FFT2D_FIXED_INTEGER_BITS
```

To run C simulation for several `ap_fixed<W,I>` formats on `square`, `gradient`, `checker`, and `circle` 64x64:

```cmd
C:\AMDDesignTools\2025.2\Vitis\bin\vitis-run.bat --mode hls --tcl run_hls_csim_bitwidth_sweep_64.tcl
```

To synthesize the formats that passed the sweep:

```cmd
C:\AMDDesignTools\2025.2\Vitis\bin\vitis-run.bat --mode hls --tcl run_hls_csynth_bitwidth_pass_64.tcl
```

Current sweep result:

| Format | Samples passed | Worst Real MaxAbs | Worst Imag MaxAbs | BRAM_18K | DSP | FF | LUT | Status |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| `ap_fixed<32,20>` | 4/4 | 48.1013 | 28.9254 | 26 | 8 | 10313 | 12128 | PASS |
| `ap_fixed<28,20>` | 4/4 | 390.4006 | 207.5461 | 24 | 8 | 9795 | 12026 | PASS |
| `ap_fixed<24,20>` | 0/4 | 4928.0017 | 2978.3820 | - | - | - | - | FAIL |
| `ap_fixed<22,20>` | 0/4 | 44172.9983 | 16776.6214 | - | - | - | - | FAIL |
| `ap_fixed<24,16>` | 0/4 | 489472.0039 | 135975.3825 | - | - | - | - | FAIL |
| `ap_fixed<24,12>` | 0/4 | 520192.0002 | 166695.3788 | - | - | - | - | FAIL |
| `ap_fixed<20,12>` | 0/4 | 520192.0039 | 166695.3825 | - | - | - | - | FAIL |

The useful next candidate is `ap_fixed<28,20>`: it passes the current multi-sample accuracy gate and slightly reduces BRAM, FF, and LUT. The formats with fewer integer bits fail because the 64x64 FFT can produce large intermediate and output values.

## Selected-format C/RTL co-simulation

The selected `ap_fixed<28,20>` format also passes C/RTL co-simulation on the four 64x64 samples.

| Sample | Co-sim | RTL latency (cycles) | Real MAE | Real MaxAbs | Imag MAE | Imag MaxAbs | Accuracy |
|---|---|---:|---:|---:|---:|---:|---|
| `square` | Pass | 420207 | 2.3940 | 256.3373 | 1.6828 | 91.8750 | PASS |
| `gradient` | Pass | 420207 | 0.3415 | 93.1718 | 0.5031 | 202.1214 | PASS |
| `checker` | Pass | 420207 | 1.5384 | 390.4006 | 0.6143 | 207.5461 | PASS |
| `circle` | Pass | 420207 | 4.3268 | 240.1185 | 3.0387 | 87.1992 | PASS |

Summary: 4/4 samples passed, with fixed RTL latency of 420207 cycles per 64x64 frame in this baseline memory-mapped implementation.

## Current Vitis HLS result

Tested with AMD Vitis HLS 2025.2, target part `xc7z020clg400-1`, 10 ns target clock.

```text
C simulation: PASS
C synthesis: PASS
C/RTL co-simulation: PASS
Estimated clock: 7.300 ns
Estimated Fmax: 136.99 MHz
Resource estimate: BRAM_18K 26 / DSP 8 / FF 10313 / LUT 12126
```

Current fixed-point accuracy against Python reference after twiddle lookup optimization:

```text
Selected format: ap_fixed<28,20>
C/RTL co-simulation: PASS on square, gradient, checker, circle
RTL latency: 420207 cycles per 64x64 sample
Worst Real MaxAbs: 390.4006
Worst Imag MaxAbs: 207.5461
```

## Resource optimization note

The first HLS version generated twiddle factors with runtime `std::sin()` and `std::cos()` inside the FFT stages. That version passed simulation, but it used too many DSP blocks.

The current version replaces those calls with fixed 64-point twiddle lookup tables. This keeps the same FFT convention while making the hardware much smaller.

| Version | BRAM_18K | DSP | FF | LUT |
|---|---:|---:|---:|---:|
| Runtime `sin/cos` | 42 | 186 | 20509 | 29674 |
| Twiddle lookup table | 26 | 8 | 10313 | 12126 |

This is the preferred baseline before moving to Vivado integration.
