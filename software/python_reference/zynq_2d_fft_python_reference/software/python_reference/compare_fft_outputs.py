"""
compare_fft_outputs.py

Compare C++/HLS/FPGA FFT output against Python NumPy reference.

Expected input:
- reference real .txt
- reference imag .txt
- test real .txt
- test imag .txt

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
    parser.add_argument("--ref-real", required=True)
    parser.add_argument("--ref-imag", required=True)
    parser.add_argument("--test-real", required=True)
    parser.add_argument("--test-imag", required=True)
    args = parser.parse_args()

    ref_real = load_txt(Path(args.ref_real))
    ref_imag = load_txt(Path(args.ref_imag))
    test_real = load_txt(Path(args.test_real))
    test_imag = load_txt(Path(args.test_imag))

    metrics = {
        "real": compute_metrics(ref_real, test_real),
        "imag": compute_metrics(ref_imag, test_imag),
    }

    print(metrics)


if __name__ == "__main__":
    main()
