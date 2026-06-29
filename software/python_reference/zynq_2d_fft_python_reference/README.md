# Zynq 2D FFT - Python Reference

This folder is the first step of the project: generating a trusted Python reference for later C++/HLS/FPGA comparison.

## What is generated

For each input image, the script saves:

- input grayscale image
- input matrix as 2D `.txt`
- input matrix as flattened row-major `.txt`
- raw FFT real output
- raw FFT imaginary output
- FFT magnitude/log-magnitude values
- shifted and unshifted log-magnitude visualization images

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
  - `*_fft_real_2d.txt`
  - `*_fft_imag_2d.txt`
  - or the `*_flat_row_major.txt` files for stream/DMA-style input/output.
- The input matrix shape follows Python convention: `[height][width]`.
- Flattened files are row-major.
