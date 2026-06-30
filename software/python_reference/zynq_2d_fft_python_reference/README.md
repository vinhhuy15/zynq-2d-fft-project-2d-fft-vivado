# Zynq 2D FFT - Python Reference

This folder is the first step of the project: generating a trusted Python reference for later C++/HLS/FPGA comparison.

Current workflow: RGB color image FFT. The script treats a color image as three independent channels and computes one 2D FFT for R, one for G, and one for B.

## What is generated

For each input image, the script saves:

- input RGB image
- per-channel input matrices as 2D `.txt`: `*_r_matrix_2d.txt`, `*_g_matrix_2d.txt`, `*_b_matrix_2d.txt`
- per-channel input matrices as flattened row-major `.txt`
- per-channel raw FFT real output
- per-channel raw FFT imaginary output
- per-channel FFT magnitude/log-magnitude values
- per-channel shifted and unshifted log-magnitude visualization images

## Run with generated sample images

```bash
python software/python_reference/fft2_reference.py --sample all --width 64 --height 64 --out .
```

## Run with your own image

```bash
python software/python_reference/fft2_reference.py --image my_image.png --width 64 --height 64 --out .
```

## Important notes

- Raw FFT output is saved without `fftshift`.
- `fftshift` is used only for visualization so the low-frequency component appears in the center.
- For C++/HLS comparison, use:
  - `*_r_fft_real_2d.txt`, `*_g_fft_real_2d.txt`, `*_b_fft_real_2d.txt`
  - `*_r_fft_imag_2d.txt`, `*_g_fft_imag_2d.txt`, `*_b_fft_imag_2d.txt`
  - or the `*_flat_row_major.txt` files for stream/DMA-style input/output.
- Each channel matrix shape follows Python convention: `[height][width]`.
- Flattened files are row-major.
