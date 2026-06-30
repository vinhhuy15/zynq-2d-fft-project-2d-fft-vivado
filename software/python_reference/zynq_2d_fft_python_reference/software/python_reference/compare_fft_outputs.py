"""
compare_fft_outputs.py

Compare C++/HLS/FPGA FFT output against Python NumPy reference.

Expected input:
- either one reference/test real/imag pair
- or three reference/test real/imag pairs for RGB color FFT

All files can be either 2D text matrices or flattened row-major text.
"""

from pathlib import Path
import argparse
import numpy as np


def load_txt(path: Path) -> np.ndarray:
    return np.loadtxt(path, dtype=np.float64)


def compute_metrics(ref: np.ndarray, test: np.ndarray) -> dict:
    ref = ref.reshape(-1)
    test = test.reshape(-1)
    diff = test - ref
    return {
        "mae": float(np.mean(np.abs(diff))),
        "mse": float(np.mean(diff ** 2)),
        "rmse": float(np.sqrt(np.mean(diff ** 2))),
        "max_abs_error": float(np.max(np.abs(diff))),
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--ref-real", required=True, nargs="+")
    parser.add_argument("--ref-imag", required=True, nargs="+")
    parser.add_argument("--test-real", required=True, nargs="+")
    parser.add_argument("--test-imag", required=True, nargs="+")
    parser.add_argument("--channels", nargs="*", default=None,
                        help="Optional labels, for example: r g b.")
    args = parser.parse_args()

    counts = {len(args.ref_real), len(args.ref_imag), len(args.test_real), len(args.test_imag)}
    if len(counts) != 1:
        raise ValueError("ref-real, ref-imag, test-real, and test-imag must have the same number of files.")

    count = counts.pop()
    labels = args.channels if args.channels else [str(i) for i in range(count)]
    if len(labels) != count:
        raise ValueError("--channels must match the number of file groups.")

    metrics = {}
    for i, label in enumerate(labels):
        ref_real = load_txt(Path(args.ref_real[i]))
        ref_imag = load_txt(Path(args.ref_imag[i]))
        test_real = load_txt(Path(args.test_real[i]))
        test_imag = load_txt(Path(args.test_imag[i]))

        metrics[label] = {
            "real": compute_metrics(ref_real, test_real),
            "imag": compute_metrics(ref_imag, test_imag),
        }

    print(metrics)


if __name__ == "__main__":
    main()
