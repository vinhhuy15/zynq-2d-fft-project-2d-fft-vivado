# PYNQ-Z1 Board Benchmark

The application in `src/main.c` runs directly on the ARM Cortex-A9 of the
PYNQ-Z1. It has three distinct responsibilities:

1. Measure a PS software FFT and the end-to-end PL accelerator call on the same
   board and input.
2. Compare the FPGA output against coefficients generated from the exact
   fixed-point input by NumPy.
3. Optionally dump the complete FPGA spectrum over UART for offline rendering.

These modes intentionally use separate log records so that a visualization dump
cannot be mistaken for a timing run.

## Build and run

Prerequisites:

- AMD Vitis Unified IDE 2025.2
- the `fft_rgb.xsa` exported by the Vivado design
- PYNQ-Z1 connected through JTAG and UART

Open the repository's `vitis` folder as the workspace, refresh `fft_platform`
from `../vivado_2d_FFT/fft_rgb.xsa`, then build and run `fft_dump_app` on the
`standalone_ps7_cortexa9_0` domain.

## Timing records

The primary record is:

```text
BOARD_BENCHMARK_RESULT,run,sample,cpu_ticks,cpu_us,fpga_ticks,fpga_us,speedup,status
```

- `cpu_us` is the Q15 lookup-table software FFT on the Cortex-A9.
- `fpga_us` includes cache maintenance, AXI/DDR traffic, accelerator polling,
  and the PL computation.
- `speedup` is `cpu_us / fpga_us`; a value below 1 means the measured end-to-end
  FPGA path is slower than this CPU baseline.
- `status` reports the coefficient-level verification result.

The optional high-precision reference record is:

```text
REFERENCE_BENCHMARK_RESULT,run,sample,cpu_double_runtime_trig_ticks,cpu_double_runtime_trig_us,fpga_us,fpga_vs_reference_speedup,status
```

This compares the FPGA with a `double` CPU implementation that evaluates
`sin`/`cos` at runtime. It is a useful reference baseline, but it is not an
optimized fixed-point CPU implementation. Any report or CV claim must name this
baseline explicitly.

Three runs are emitted by default. Archive the complete UART log whenever a board
speedup number is published.

## NumPy coefficient check

For `synthetic_checker`, the application emits one record per channel:

```text
PYTHON_REFERENCE_RESULT,synthetic_checker,R,real_mae_raw,real_maxabs_raw,imag_mae_raw,imag_maxabs_raw,status
```

Regenerate `src/checker_python_reference.h` from the same Q12 test input with:

```powershell
python tools/generate_vitis_checker_reference.py
```

This avoids comparing different input scales.

## Full UART spectrum dump

Timing mode keeps `ENABLE_FULL_UART_DUMP` set to `0`. For visualization only,
change it to `1`, rebuild, and capture the entire UART stream:

```text
FFT_DUMP_BEGIN,synthetic_checker,64,64,3
D,channel,bin,real_hex,imag_hex
...
FFT_DUMP_END,synthetic_checker
```

Render the captured output on the host:

```powershell
python tools/render_fpga_fft_dump.py `
  --log path/to/fpga_checker_uart.log `
  --out data/fpga_fft_from_uart
```

The renderer writes hardware spectra, NumPy spectra, comparison sheets, and a
JSON summary. A full dump is deliberately excluded from the benchmark timing.
