# Zynq-7000 RGB 2D FFT Accelerator

This repository contains the source code and paper artifacts for a 2D FFT accelerator for RGB image processing on a Zynq-7000/PYNQ-Z1 FPGA.

## Links

- GitHub repository: https://github.com/vinhhuy15/zynq-2d-fft-project-2d-fft-vivado
- Demo video: https://youtu.be/MT-Wih9r9Ww?si=f5bfxOD89rCQIJ0p

## Main Contents

- `hls/fft2d_accel`: Vitis HLS implementation, fixed-point FFT source, testbench, and reproduction scripts for paper numbers.
- `vitis/fft_dump_app`: Vitis bare-metal application used to run the accelerator and dump FFT outputs from the board.
- `pynq/run_fpga_fft_spectrum.py`: PYNQ-side helper for running the accelerator and generating FFT spectrum images.
- `tools`: scripts for generating demo inputs, capturing UART logs, and rendering FPGA FFT dumps.
- `paper/report_HWSW`: IEEE-style paper source, figures, references, and compiled PDF.

## Paper

The latest compiled paper is available at:

```text
paper/report_HWSW/zynq_rgb_fft_ieee_draft.pdf
```

