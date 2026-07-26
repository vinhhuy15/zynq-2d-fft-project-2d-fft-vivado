from pathlib import Path
import argparse
import re

import numpy as np


FFT_SIZE = 64
CHANNELS = ("r", "g", "b")
FIXED_SCALE = 4096.0


def parse_first_input_array(header_path: Path) -> np.ndarray:
    text = header_path.read_text(encoding="utf-8")
    match = re.search(
        r"static const uint32_t rgb_test_0_input\[RGB_IMAGE_TEST_SAMPLES\]\s*=\s*\{(.*?)\};",
        text,
        re.S,
    )
    if match is None:
        raise SystemExit(f"Cannot find rgb_test_0_input in {header_path}")

    values = [int(token, 16) for token in re.findall(r"0x([0-9a-fA-F]{8})U", match.group(1))]
    expected = 3 * FFT_SIZE * FFT_SIZE
    if len(values) != expected:
        raise SystemExit(f"Expected {expected} samples, found {len(values)}")
    return np.asarray(values, dtype=np.int32).reshape(3, FFT_SIZE, FFT_SIZE)


def c_array(name: str, values: np.ndarray) -> list[str]:
    flat = values.reshape(-1).astype(np.int32)
    lines = [f"static const int32_t {name}[CHECKER_REF_SAMPLES] = {{"]
    for start in range(0, flat.size, 8):
        chunk = ", ".join(str(int(v)) for v in flat[start : start + 8])
        lines.append(f"    {chunk},")
    lines.append("};")
    return lines


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Generate the full NumPy FFT reference used by the PYNQ-Z1 checker test."
    )
    parser.add_argument(
        "--input-header",
        type=Path,
        help="Generated RGB test header (defaults to the fft_dump_app header).",
    )
    parser.add_argument(
        "--output-header",
        type=Path,
        help="Destination C header (defaults beside the input header).",
    )
    args = parser.parse_args()

    repo = Path(__file__).resolve().parents[1]
    input_header = args.input_header or (
        repo / "vitis" / "fft_dump_app" / "src" / "rgb_image_fft_tests.h"
    )
    output_header = args.output_header or input_header.with_name("checker_python_reference.h")

    raw = parse_first_input_array(input_header)
    fixed = raw.astype(np.float64) / FIXED_SCALE
    real_refs = []
    imag_refs = []

    for ch_idx, _ch_name in enumerate(CHANNELS):
        spectrum = np.fft.fft2(fixed[ch_idx])
        real_refs.append(np.rint(np.real(spectrum) * FIXED_SCALE).astype(np.int32))
        imag_refs.append(np.rint(np.imag(spectrum) * FIXED_SCALE).astype(np.int32))

    lines = [
        "#ifndef CHECKER_PYTHON_REFERENCE_H",
        "#define CHECKER_PYTHON_REFERENCE_H",
        "",
        "#include <stdint.h>",
        "",
        "#define CHECKER_REF_TEST_INDEX 0U",
        '#define CHECKER_REF_NAME "synthetic_checker"',
        "#define CHECKER_REF_SAMPLES (3U * 64U * 64U)",
        "",
        "/*",
        " * Python FFT reference generated from rgb_test_0_input in rgb_image_fft_tests.h.",
        " * Values are stored in the same raw fixed-point scale used by the HLS IP output.",
        " */",
    ]
    lines.extend(c_array("checker_ref_real_raw", np.stack(real_refs, axis=0)))
    lines.append("")
    lines.extend(c_array("checker_ref_imag_raw", np.stack(imag_refs, axis=0)))
    lines.append("")
    lines.append("#endif")
    lines.append("")

    output_header.write_text("\n".join(lines), encoding="utf-8")
    print(f"Wrote {output_header}")


if __name__ == "__main__":
    main()
