# Vitis HLS RGB 2D FFT Core

This directory contains the synthesizable FFT accelerator, its portable
testbench, and the scripts used to reproduce the paper's HLS results.

## Design contract

- Input: RGB tensor `[3][64][64]`
- Output: raw, unshifted real and imaginary tensors with the same shape
- Algorithm: separable row-column radix-2 FFT
- Selected arithmetic:
  `ap_fixed<28,20,AP_RND,AP_SAT>`
- Target: PYNQ-Z1 / `xc7z020clg400-1`
- Target clock: 10 ns
- Interfaces: AXI4-Lite control plus three AXI master memory ports

The compile-time checks in `include/fft2d_fixed.hpp` require power-of-two
dimensions from 2 through 64 and exactly three channels.

## Portable numerical verification

The desktop build uses `double` while preserving the same FFT data flow. It
compares all coefficients with checked-in NumPy output for four deterministic
RGB images.

Linux/macOS:

```bash
make run-all-64
```

Windows PowerShell:

```powershell
./build_and_run_windows.ps1
```

The summary is written to:

```text
results/portable/hls_prep_color_accuracy_64x64.csv
```

The test passes when every output has MaxAbs error at most `1e-6`. Generated
matrices stay under `build/portable-output` and `make clean` removes only
portable build output; it never deletes archived HLS evidence.

## HLS reproduction

AMD Vitis HLS 2025.2 uses `vitis-run` for these Tcl flows. Start from a terminal
where the AMD toolchain environment has been loaded:

```powershell
vitis-run --mode hls --tcl run_hls_csim.tcl
vitis-run --mode hls --tcl run_hls_csynth.tcl
vitis-run --mode hls --tcl run_hls_cosim_28_20_64.tcl
```

To reproduce the bit-width sweep and runtime-trigonometry comparison in one
flow:

```powershell
./run_paper_reproduce_windows.ps1
```

If Vitis is installed in a non-default location:

```powershell
./run_paper_reproduce_windows.ps1 `
  -VitisRun "C:\path\to\Vitis\bin\vitis-run.bat"
```

To regenerate only the CSV, Markdown, and SVG summaries from existing reports:

```powershell
./run_paper_reproduce_windows.ps1 -SkipHls
```

## Archived HLS results

The paper reproduction flow currently records:

| Variant | BRAM_18K | DSP | FF | LUT (top summary) |
|---|---:|---:|---:|---:|
| Runtime `sin`/`cos` | 78 | 197 | 18,271 | 25,593 |
| Twiddle LUT, `28,20` | 66 | 8 | 9,869 | 12,375 |
| Reduction | 15.4% | 95.9% | 46.0% | 51.6% |

The detailed Twiddle LUT report lists 12,377 LUT, two more than the top-level
summary. The paper labels and uses the detailed value; both source values are
retained for auditability.

### Fixed-point selection

| Format | Samples passed | Worst Real MaxAbs | Worst Imag MaxAbs | Status |
|---|---:|---:|---:|---|
| `ap_fixed<32,20>` | 4/4 | 48.1013 | 34.5814 | PASS |
| `ap_fixed<28,20>` | 4/4 | 390.4006 | 308.7507 | PASS |
| `ap_fixed<24,20>` | 0/4 | 4,928.0017 | 3,312.7220 | FAIL |
| `ap_fixed<22,20>` | 0/4 | 44,172.9983 | 30,855.2780 | FAIL |
| `ap_fixed<24,16>` | 0/4 | 489,472.0039 | 295,416.7260 | FAIL |
| `ap_fixed<24,12>` | 0/4 | 520,192.0002 | 326,136.7223 | FAIL |
| `ap_fixed<20,12>` | 0/4 | 520,192.0039 | 326,136.7260 | FAIL |

A candidate passes only when real and imaginary MaxAbs are at most 1024 for all
four samples. The `28,20` format is selected because it passes this gate with
less storage and logic than `32,20`; it is not the minimum-error format.

### C/RTL co-simulation

| Sample | Latency (cycles) | Real MAE | Real MaxAbs | Imag MAE | Imag MaxAbs |
|---|---:|---:|---:|---:|---:|
| square | 420,207 | 2.3940 | 256.3373 | 1.6828 | 91.8750 |
| gradient | 420,207 | 0.3415 | 93.2577 | 0.5043 | 202.1839 |
| checker | 420,207 | 1.5384 | 390.4006 | 0.6143 | 308.7507 |
| circle | 420,207 | 4.3268 | 240.1185 | 3.0387 | 87.1992 |

All samples pass. At 100 MHz, 420,207 cycles correspond to approximately
4.202 ms per RGB frame for this memory-mapped baseline.

## Important files

| File | Purpose |
|---|---|
| `include/fft2d_fixed.hpp` | Dimensions, fixed-point type, and top declaration |
| `src/fft2d_fixed.cpp` | Lookup-table radix-2 row-column FFT |
| `src/fft2d_fixed_runtime_trig.cpp` | Resource-comparison baseline |
| `tb/testbench.cpp` | Coefficient-level reference comparison |
| `run_hls_cosim_28_20_64.tcl` | Selected-format C/RTL co-simulation |
| `run_hls_paper_tables_64.tcl` | Paper bit-width/resource experiments |
| `run_paper_reproduce_windows.ps1` | End-to-end paper evidence driver |
| `tools/collect_paper_hls_results.py` | Report parser and summary generator |

Generated HLS projects and logs are deliberately ignored. Only curated summaries
and source reports needed to substantiate published numbers belong in Git.
