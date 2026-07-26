# RGB 2D FFT Accelerator on Zynq-7000

[![Portable FFT verification](https://github.com/vinhhuy15/zynq-2d-fft-project-2d-fft-vivado/actions/workflows/portable-verification.yml/badge.svg)](https://github.com/vinhhuy15/zynq-2d-fft-project-2d-fft-vivado/actions/workflows/portable-verification.yml)

A hardware/software co-design project that accelerates a `64 x 64` two-dimensional
FFT for three-channel RGB images on a PYNQ-Z1. The design combines a
fixed-point, radix-2 Vitis HLS core with a Zynq Processing System controller,
AXI memory-mapped DDR access, board-side verification, and a NumPy reference
pipeline.

[Demo video](https://youtu.be/MT-Wih9r9Ww) ·
[IEEE-style paper](paper/report_HWSW/zynq_rgb_fft_ieee_draft.pdf) ·
[Reproduction specification](research_spec.md)

## Highlights

- Implemented a separable row-column FFT using a reusable 64-point radix-2
  kernel for all RGB channels.
- Replaced runtime `sin`/`cos` with a static twiddle lookup table, reducing HLS
  DSP usage from 197 to 8 in the archived comparison.
- Evaluated seven fixed-point formats and selected
  `ap_fixed<28,20,AP_RND,AP_SAT>` using a coefficient-level accuracy gate.
- Integrated the IP with Zynq PS through AXI4-Lite control and three AXI master
  DDR interfaces.
- Verified the numerical path against NumPy, then through HLS C simulation,
  C/RTL co-simulation, Vivado implementation, and PYNQ-Z1 board software.
- Added a portable C++ verification path that runs without Vivado or Vitis and
  checks four deterministic RGB images in CI.

## Architecture

```text
                         AXI4-Lite control
ARM Cortex-A9 (PS)  ---------------------------->  2D FFT HLS IP (PL)
       |                                                   |
       | prepare / verify                                  | AXI masters
       v                                                   v
  DDR input RGB  <---- AXI interconnect ---->  DDR real + imaginary output
                                             row FFT -> column FFT per channel
```

Input and output tensors use channel-major shape `[3][64][64]`. The accelerator
returns raw, unshifted real and imaginary FFT coefficients; `fftshift` is used
only when rendering spectra.

## Results

The values below are tied to the checked-in reproduction reports described in
[`research_spec.md`](research_spec.md).

| Metric | Result |
|---|---:|
| Selected format | `ap_fixed<28,20>` |
| Fixed-point validation | 4/4 RGB samples pass |
| C/RTL latency | 420,207 cycles/frame |
| Latency at 100 MHz | 4.202 ms/frame |
| HLS resources | 66 BRAM_18K, 8 DSP, 9,869 FF, 12,375 LUT |
| DSP reduction vs runtime trig | 95.9% |
| Post-implementation WNS / WHS | 0.668 ns / 0.012 ns |
| Estimated on-chip power | 1.493 W |

The HLS top summary reports 12,375 LUT while its detailed synthesis section
reports 12,377; the paper uses the detailed value. Integrated Vivado utilization
also includes PS, interconnect, reset, and debug logic, so it is intentionally
not mixed with the IP-level table above.

The paper discusses an additional board measurement against a
double/runtime-trigonometry CPU reference. The raw UART log for that measurement
is not currently archived, so this repository does not present the speedup as an
independently reproducible headline result.

## Quick verification (no AMD tools required)

Prerequisites: a C++17 compiler and `make`, or GCC on Windows with PowerShell.

Linux/macOS:

```bash
cd hls/fft2d_accel
make run-all-64
```

Windows PowerShell:

```powershell
cd hls/fft2d_accel
./build_and_run_windows.ps1
```

Both commands compare the C++ FFT with the checked-in NumPy coefficients for
`square`, `gradient`, `checker`, and `circle`. The CSV summary is written to
`hls/fft2d_accel/results/portable/`.

For the host-side visualization tools:

```bash
python -m pip install -r requirements.txt
python tools/generate_vitis_checker_reference.py --help
python tools/render_fpga_fft_dump.py --help
```

## Full hardware flow

The full flow requires AMD Vitis/Vivado 2025.2 and a PYNQ-Z1:

1. Run the HLS reproduction scripts in [`hls/fft2d_accel`](hls/fft2d_accel).
2. Open [`vivado_2d_FFT/project_1.xpr`](vivado_2d_FFT/project_1.xpr), or run
   `build_bitstream_and_export_xsa.tcl`, to build and export `fft_rgb.xsa`.
3. Open `vitis` as a workspace, refresh `fft_platform` from the XSA, and build
   `fft_dump_app`.
4. Program the board, capture the UART benchmark, and optionally render a full
   spectrum dump with `tools/render_fpga_fft_dump.py`.

See [`vitis/fft_dump_app/BOARD_BENCHMARK_README.md`](vitis/fft_dump_app/BOARD_BENCHMARK_README.md)
for the log schema and measurement boundaries.

## Repository layout

| Path | Purpose |
|---|---|
| `hls/fft2d_accel/` | Synthesizable C++, testbench, HLS scripts, and evidence |
| `software/python_reference/` | NumPy ground truth and deterministic input data |
| `vivado_2d_FFT/` | Zynq block design, build scripts, constraints, and exported XSA |
| `vitis/fft_dump_app/` | Bare-metal PS controller, board benchmark, and UART dump |
| `tools/` | Test-vector generation, UART capture, and spectrum rendering |
| `pynq/` | PYNQ-side accelerator helper |
| `paper/report_HWSW/` | Paper source, bibliography, figures, and compiled PDF |
| `research_spec.md` | Claim-to-code mapping, protocol, assumptions, and limitations |

Generated HLS/Vivado/Vitis workspaces, BSP sources, netlists, caches, and local
office files are intentionally excluded from version control.

## Team

Giang Vĩnh Huy, Nguyễn Quang Nhơn, Phạm Đình Phước, Nguyễn Lâm Minh Nhật, and
Đoàn Nhật Hoà — Department of Computer Engineering, HCMUTE.
