# Research Reproduction Specification

## Project

**Title:** A 2D FFT Accelerator for RGB Image Processing on Zynq-7000 FPGA

**Repository role:** This repository is the implementation and evidence package for a
course/research project, not a reproduction of a third-party implementation. The
specification below records what is observable in the source tree and separates it
from claims that still require an archived measurement.

## Objective

Accelerate a fixed-size `64 x 64` two-dimensional FFT on the three channels of an
RGB image using the programmable logic of a PYNQ-Z1 (`xc7z020clg400-1`). The
Processing System prepares DDR buffers and controls the accelerator; the
Programmable Logic performs the row-column FFT and returns raw real and imaginary
coefficients.

## Baselines and Proposed Design

### Numerical baseline

- NumPy `fft2` independently processes the R, G, and B channels.
- Raw, unshifted real/imaginary coefficients are the comparison target.
- Four deterministic synthetic images are used: square, gradient, checker, and
  circle.

### Hardware baseline

- Radix-2 decimation-in-time 1D FFT reused for all rows and columns.
- Runtime `sin`/`cos` generates twiddle factors.
- The baseline is used only for the HLS resource comparison.

### Proposed design

- Same row-column radix-2 data flow.
- A static 64-point twiddle lookup table replaces runtime trigonometry.
- `ap_fixed<28,20,AP_RND,AP_SAT>` is the selected fixed-point format.
- Three AXI master ports access input, real-output, and imaginary-output buffers.
- AXI4-Lite exposes buffer addresses and accelerator control.

## Module and Data-Flow Mapping

| Stage | Shape / format | Implementation |
|---|---|---|
| Reference input generation | `3 x 64 x 64`, floating point | `software/python_reference/.../fft2_reference.py` |
| Reference FFT | three complex `64 x 64` matrices | NumPy `fft2` in the same script |
| HLS input | `data_t[3][64][64]` | `hls/fft2d_accel/include/fft2d_fixed.hpp` |
| Row FFT | 192 independent 64-point FFTs | `fft1d_fixed` in `src/fft2d_fixed.cpp` |
| Column FFT | 192 independent 64-point FFTs | `fft1d_fixed_col` in `src/fft2d_fixed.cpp` |
| HLS output | real and imaginary `data_t[3][64][64]` | `fft2d_fixed_top` |
| Desktop/HLS check | MAE, RMSE, MaxAbs | `hls/fft2d_accel/tb/testbench.cpp` |
| Board control and timing | Q12 raw buffers in DDR | `vitis/fft_dump_app/src/main.c` |
| FPGA spectrum rendering | UART hex dump to PNG/JSON | `tools/render_fpga_fft_dump.py` |

End-to-end flow:

```text
RGB image
  -> per-channel 64 x 64 matrices
  -> row-wise 64-point FFT
  -> column-wise 64-point FFT
  -> raw real/imaginary DDR buffers
  -> numerical comparison and spectrum rendering
```

## Key Equations

The two-dimensional DFT used by the reference is:

```text
F(u,v) = sum_x sum_y f(x,y) exp(-j 2 pi (u x / M + v y / N))
```

The implementation uses separability:

```text
G(u,y) = FFT_x(f(x,y))
F(u,v) = FFT_y(G(u,y))
```

Each radix-2 butterfly applies:

```text
t = odd * W_N^k
even' = even + t
odd'  = even - t
```

The lookup-table index in the current fixed 64-point implementation is
`k * 64 / stage_length`.

## Experimental Protocol

### Toolchain

- AMD Vitis HLS / Vivado 2025.2
- Target part: `xc7z020clg400-1`
- Target clock: 10 ns (100 MHz)
- Fixed image size: RGB `64 x 64`

### Accuracy

- Compare every raw real and imaginary coefficient with the NumPy reference.
- Report MAE and MaxAbs.
- A fixed-point candidate passes when both real and imaginary MaxAbs are at most
  1024 for all four samples.

### HLS resources and latency

- Compare runtime-trigonometry and lookup-table variants using reports generated
  by the same reproduction flow.
- Record BRAM_18K, DSP, FF, LUT, estimated clock, and C/RTL latency.
- Preserve the source `.rpt`/`.xml` files used to derive published summary tables.

### Integrated design

- Record post-implementation WNS/WHS, utilization, and estimated power from
  Vivado reports or screenshots.
- Keep IP-level HLS resource numbers distinct from whole-system Vivado
  utilization.

### Board benchmark

- Run the PS software and PL accelerator on the same PYNQ-Z1 input.
- Treat cache maintenance, AXI/DDR access, and polling as part of end-to-end FPGA
  time when reporting `fpga_us`.
- Label the CPU comparison precisely: optimized fixed-point PS baseline and
  double/runtime-trigonometry reference are different baselines.

## Expected and Archived Results

The current `results/paper_reproduce_64` reports support:

- Runtime trigonometry: 78 BRAM_18K, 197 DSP, 18,271 FF, 25,593 LUT.
- Twiddle LUT (`28,20`): 66 BRAM_18K, 8 DSP, 9,869 FF, 12,375 LUT in the
  top-level summary (12,377 LUT in the detailed synthesis section).
- DSP reduction: approximately 95.9%.
- `ap_fixed<28,20>`: 4/4 samples pass the MaxAbs <= 1024 gate.
- Selected-format C/RTL latency reported by the checked-in experiment artifacts:
  420,207 cycles for a `64 x 64` RGB frame.
- Post-implementation evidence shown in the paper: WNS 0.668 ns, WHS 0.012 ns,
  and estimated on-chip power 1.493 W.

## Ambiguities and Limitations

1. The HLS top summary reports 12,375 LUT while the detailed report and paper use
   12,377. Both values must be labeled by report section rather than silently
   mixed.
2. The old HLS README contains resource values from an earlier run
   (26 BRAM_18K, 8 DSP, 10,313 FF, 12,126 LUT). These are not the same report set
   used by the current paper and must not be presented as the current result.
3. The paper states an approximately 2.2x board speedup against the
   double/runtime-trigonometry PS reference, but no raw UART benchmark log is
   currently archived in the repository. This claim is therefore
   **reported-but-not-reproducible from the repository alone**.
4. Vivado screenshots support timing, utilization, and power claims, but the raw
   text reports are not currently archived.
5. The design supports only power-of-two dimensions up to 64, while the current
   source enforces only the upper bound at compile time.
6. Full AMD tool runs and board measurements cannot be reproduced on a generic CI
   runner; CI can verify only the portable C++ and Python reference paths.

## Verification Checklist

- [x] Generate all four deterministic NumPy reference inputs.
- [x] Build and run the portable C++ testbench on all four inputs.
- [x] Verify near-zero error for the desktop `double` implementation.
- [x] Run HLS C simulation for `ap_fixed<28,20>` (archived experiment).
- [x] Run C synthesis and compare the source report with the checked-in summary.
- [x] Run C/RTL co-simulation and confirm the fixed latency and accuracy gate
      (archived experiment).
- [x] Build the Vivado design and confirm positive WNS/WHS (paper evidence).
- [ ] Build the Vitis board app from the exported XSA.
- [ ] Archive a complete UART benchmark log before presenting board speedup as
      independently reproducible.
- [ ] Keep generated workspaces, caches, BSP sources, and netlists out of Git.
