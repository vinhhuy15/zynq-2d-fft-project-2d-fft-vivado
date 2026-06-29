"""
fft2_reference.py

Python reference generator for a Zynq-7000 2D FFT project.

What this script does:
1. Reads an input image or generates sample grayscale images.
2. Resizes the image to a fixed FFT size such as 32x32 or 64x64.
3. Saves the input matrix as .txt for C++/HLS testbench input.
4. Computes 2D FFT with NumPy.
5. Saves real and imaginary reference outputs as .txt.
6. Saves magnitude/log-magnitude images for visual checking.

Raw FFT output is NOT shifted.
Shifted magnitude image is only for visualization.
"""

from pathlib import Path
import argparse
import numpy as np
from PIL import Image, ImageDraw


def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def load_grayscale_image(image_path: Path, width: int, height: int) -> np.ndarray:
    """Load image, convert to grayscale uint8, and resize."""
    img = Image.open(image_path).convert("L")
    img = img.resize((width, height), Image.Resampling.LANCZOS)
    return np.asarray(img, dtype=np.float64)


def generate_sample_image(kind: str, width: int, height: int) -> np.ndarray:
    """Generate simple deterministic grayscale test images."""
    if kind == "square":
        arr = np.zeros((height, width), dtype=np.float64)
        y0, y1 = height // 4, 3 * height // 4
        x0, x1 = width // 4, 3 * width // 4
        arr[y0:y1, x0:x1] = 255.0
        return arr

    if kind == "gradient":
        x = np.linspace(0, 255, width, dtype=np.float64)
        return np.tile(x, (height, 1))

    if kind == "checker":
        yy, xx = np.indices((height, width))
        block = max(2, min(width, height) // 8)
        arr = (((xx // block) + (yy // block)) % 2) * 255.0
        return arr.astype(np.float64)

    if kind == "circle":
        arr = np.zeros((height, width), dtype=np.float64)
        yy, xx = np.indices((height, width))
        cy, cx = height / 2.0, width / 2.0
        r = min(width, height) / 4.0
        mask = (xx - cx) ** 2 + (yy - cy) ** 2 <= r ** 2
        arr[mask] = 255.0
        return arr

    raise ValueError(f"Unknown sample kind: {kind}")


def save_input_image(arr: np.ndarray, path: Path) -> None:
    """Save grayscale input image."""
    img = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), mode="L")
    img.save(path)


def save_matrix_txt(arr: np.ndarray, path: Path, fmt: str = "%.10f") -> None:
    """
    Save matrix in row-major order as text.
    Shape is kept as 2D, so C++ can read row by row.
    """
    np.savetxt(path, arr, fmt=fmt)


def save_flat_txt(arr: np.ndarray, path: Path, fmt: str = "%.10f") -> None:
    """
    Save matrix flattened in row-major order.
    Useful for HLS stream/DMA testbenches.
    """
    np.savetxt(path, arr.reshape(-1), fmt=fmt)


def log_magnitude_image(fft_complex: np.ndarray, shifted: bool = True) -> np.ndarray:
    """
    Convert complex FFT result to 8-bit log-magnitude image.

    shifted=True centers low frequency for visualization.
    Important: this is for human display only.
    Do not compare this as raw FFT numerical output.
    """
    f = np.fft.fftshift(fft_complex) if shifted else fft_complex
    mag = np.log1p(np.abs(f))
    mn, mx = float(mag.min()), float(mag.max())

    if mx == mn:
        return np.zeros_like(mag, dtype=np.uint8)

    out = (mag - mn) * 255.0 / (mx - mn)
    return np.clip(out, 0, 255).astype(np.uint8)


def compute_fft2_reference(arr: np.ndarray) -> np.ndarray:
    """
    Compute 2D FFT reference.

    NumPy convention:
    - input shape: [height, width]
    - output shape: [height, width]
    - no normalization on forward FFT
    """
    return np.fft.fft2(arr)


def run_one(arr: np.ndarray, name: str, out_dir: Path) -> dict:
    """Run FFT reference flow for one input matrix."""
    input_dir = out_dir / "data" / "input"
    ref_dir = out_dir / "data" / "reference"
    visual_dir = out_dir / "data" / "visual"
    results_dir = out_dir / "results"

    for d in [input_dir, ref_dir, visual_dir, results_dir]:
        ensure_dir(d)

    arr = np.clip(np.rint(arr), 0, 255).astype(np.float64)
    h, w = arr.shape

    # Input files
    save_input_image(arr, input_dir / f"{name}_{w}x{h}.png")
    save_matrix_txt(arr, input_dir / f"{name}_{w}x{h}_matrix_2d.txt", fmt="%.0f")
    save_flat_txt(arr, input_dir / f"{name}_{w}x{h}_matrix_flat_row_major.txt", fmt="%.0f")

    # FFT reference
    fft_ref = compute_fft2_reference(arr)
    real = np.real(fft_ref)
    imag = np.imag(fft_ref)

    # Raw numerical output for C++/HLS comparison
    save_matrix_txt(real, ref_dir / f"{name}_{w}x{h}_fft_real_2d.txt")
    save_matrix_txt(imag, ref_dir / f"{name}_{w}x{h}_fft_imag_2d.txt")
    save_flat_txt(real, ref_dir / f"{name}_{w}x{h}_fft_real_flat_row_major.txt")
    save_flat_txt(imag, ref_dir / f"{name}_{w}x{h}_fft_imag_flat_row_major.txt")

    # Magnitude values
    mag = np.abs(fft_ref)
    log_mag = np.log1p(mag)
    save_matrix_txt(mag, ref_dir / f"{name}_{w}x{h}_fft_magnitude_2d.txt")
    save_matrix_txt(log_mag, ref_dir / f"{name}_{w}x{h}_fft_log_magnitude_2d.txt")

    # Visual output
    Image.fromarray(log_magnitude_image(fft_ref, shifted=True), mode="L").save(
        visual_dir / f"{name}_{w}x{h}_fft_log_magnitude_shifted.png"
    )
    Image.fromarray(log_magnitude_image(fft_ref, shifted=False), mode="L").save(
        visual_dir / f"{name}_{w}x{h}_fft_log_magnitude_unshifted.png"
    )

    # Summary numbers
    summary = {
        "name": name,
        "width": int(w),
        "height": int(h),
        "input_min": float(arr.min()),
        "input_max": float(arr.max()),
        "fft_real_min": float(real.min()),
        "fft_real_max": float(real.max()),
        "fft_imag_min": float(imag.min()),
        "fft_imag_max": float(imag.max()),
        "fft_magnitude_min": float(mag.min()),
        "fft_magnitude_max": float(mag.max()),
        "dc_value_real_at_0_0": float(real[0, 0]),
        "dc_value_imag_at_0_0": float(imag[0, 0]),
    }

    return summary


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--image", type=str, default=None, help="Optional input image path.")
    parser.add_argument("--width", type=int, default=64, help="FFT width, preferably power of 2.")
    parser.add_argument("--height", type=int, default=64, help="FFT height, preferably power of 2.")
    parser.add_argument("--sample", type=str, default="square",
                        choices=["square", "gradient", "checker", "circle", "all"],
                        help="Sample image to generate if --image is not used.")
    parser.add_argument("--out", type=str, default=".", help="Output project directory.")
    args = parser.parse_args()

    out_dir = Path(args.out)
    summaries = []

    if args.image:
        image_path = Path(args.image)
        arr = load_grayscale_image(image_path, args.width, args.height)
        summaries.append(run_one(arr, image_path.stem, out_dir))
    else:
        samples = ["square", "gradient", "checker", "circle"] if args.sample == "all" else [args.sample]
        for sample in samples:
            arr = generate_sample_image(sample, args.width, args.height)
            summaries.append(run_one(arr, sample, out_dir))

    ensure_dir(out_dir / "results")
    summary_path = out_dir / "results" / f"fft2_reference_summary_{args.width}x{args.height}.json"
    summary_path.write_text(
        __import__("json").dumps(summaries, indent=2),
        encoding="utf-8"
    )

    print(f"Done. Generated {len(summaries)} FFT reference set(s).")
    print(f"Summary: {summary_path}")


if __name__ == "__main__":
    main()
