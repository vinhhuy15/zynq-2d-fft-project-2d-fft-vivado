from pathlib import Path
import argparse
import json

import numpy as np
from PIL import Image


FFT_SIZE = 64
FRAC_BITS = 12
FIXED_SCALE = 1 << FRAC_BITS
CHANNELS = ("r", "g", "b")
PROBE_BINS = (0, 1, 2, 3, 7, 8, 15, 16, 31, 32, 63, 64, 65, 127, 255, 511, 1023, 2047, 4095)


def raw_to_c_literal(value: int) -> str:
    return f"0x{np.uint32(value).item():08x}U"


def to_fixed_q12(arr_u8: np.ndarray) -> np.ndarray:
    normalized = arr_u8.astype(np.float64) / 255.0
    return np.rint(normalized * FIXED_SCALE).astype(np.int32)


def make_checker() -> np.ndarray:
    yy, xx = np.indices((FFT_SIZE, FFT_SIZE))
    block = 8
    checker = (((xx // block) + (yy // block)) % 2).astype(np.uint8)
    arr = np.zeros((FFT_SIZE, FFT_SIZE, 3), dtype=np.uint8)
    arr[:, :, 0] = checker * 255
    arr[:, :, 1] = (1 - checker) * 255
    arr[:, :, 2] = ((xx // block) % 2).astype(np.uint8) * 255
    return arr


def log_magnitude_image(fft_complex: np.ndarray) -> np.ndarray:
    shifted = np.fft.fftshift(fft_complex)
    mag = np.log1p(np.abs(shifted))
    if mag.max() <= mag.min():
        return np.zeros((FFT_SIZE, FFT_SIZE), dtype=np.uint8)
    return np.rint((mag - mag.min()) * 255.0 / (mag.max() - mag.min())).astype(np.uint8)


def save_reference_visuals(name: str, arr_u8: np.ndarray, out_dir: Path) -> None:
    input_dir = out_dir / "input"
    ref_dir = out_dir / "python_reference_fft"
    recon_dir = out_dir / "python_reference_reconstructed"
    input_dir.mkdir(parents=True, exist_ok=True)
    ref_dir.mkdir(parents=True, exist_ok=True)
    recon_dir.mkdir(parents=True, exist_ok=True)

    Image.fromarray(arr_u8, mode="RGB").save(input_dir / f"{name}_64x64.png")

    fixed = to_fixed_q12(arr_u8).astype(np.float64) / FIXED_SCALE
    reconstructed = np.zeros_like(arr_u8)
    for ch_idx, ch_name in enumerate(CHANNELS):
        fft = np.fft.fft2(fixed[:, :, ch_idx])
        Image.fromarray(log_magnitude_image(fft), mode="L").save(ref_dir / f"{name}_{ch_name}_fft_python.png")
        reconstructed[:, :, ch_idx] = np.clip(np.rint(np.real(np.fft.ifft2(fft)) * 255.0), 0, 255).astype(np.uint8)

    Image.fromarray(reconstructed, mode="RGB").save(recon_dir / f"{name}_ifft_python.png")


def build_header(images: list[tuple[str, np.ndarray]], header_path: Path, out_dir: Path) -> None:
    if out_dir.exists():
        for path in sorted(out_dir.rglob("*"), reverse=True):
            if path.is_file():
                path.unlink()
            elif path.is_dir():
                path.rmdir()

    prepared = []
    manifest = []

    for name, arr_u8 in images:
        fixed_raw = to_fixed_q12(arr_u8)
        channel_major = np.transpose(fixed_raw, (2, 0, 1)).reshape(-1)
        save_reference_visuals(name, arr_u8, out_dir)

        probes = []
        fixed_value = fixed_raw.astype(np.float64) / FIXED_SCALE
        for ch_idx in range(3):
            fft = np.fft.fft2(fixed_value[:, :, ch_idx]).reshape(-1)
            for bin_idx in PROBE_BINS:
                probes.append((
                    ch_idx,
                    bin_idx,
                    np.int32(int(np.rint(np.real(fft[bin_idx]) * FIXED_SCALE))).item(),
                    np.int32(int(np.rint(np.imag(fft[bin_idx]) * FIXED_SCALE))).item(),
                ))

        prepared.append((name, channel_major.astype(np.uint32), probes))
        manifest.append({"name": name, "input": f"input/{name}_64x64.png"})

    lines = [
        "#ifndef RGB_IMAGE_FFT_TESTS_H",
        "#define RGB_IMAGE_FFT_TESTS_H",
        "",
        "#include <stdint.h>",
        "",
        "#define RGB_IMAGE_TEST_COUNT %dU" % len(prepared),
        "#define RGB_IMAGE_TEST_SAMPLES %dU" % (3 * FFT_SIZE * FFT_SIZE),
        "#define RGB_IMAGE_TEST_PROBE_COUNT %dU" % (len(PROBE_BINS) * 3),
        "",
        "typedef struct {",
        "    uint32_t channel;",
        "    uint32_t bin;",
        "    int32_t expected_real_raw;",
        "    int32_t expected_imag_raw;",
        "} rgb_fft_probe_t;",
        "",
    ]

    for idx, (_name, samples, probes) in enumerate(prepared):
        lines.append(f"static const uint32_t rgb_test_{idx}_input[RGB_IMAGE_TEST_SAMPLES] = {{")
        for start in range(0, len(samples), 8):
            lines.append("    " + ", ".join(raw_to_c_literal(int(v)) for v in samples[start:start + 8]) + ",")
        lines.append("};")
        lines.append("")
        lines.append(f"static const rgb_fft_probe_t rgb_test_{idx}_probes[RGB_IMAGE_TEST_PROBE_COUNT] = {{")
        for ch, bin_idx, real_raw, imag_raw in probes:
            lines.append(f"    {{{ch}U, {bin_idx}U, {real_raw}, {imag_raw}}},")
        lines.append("};")
        lines.append("")

    lines.append("static const char *const rgb_image_test_names[RGB_IMAGE_TEST_COUNT] = {")
    lines.extend(f'    "{name}",' for name, _samples, _probes in prepared)
    lines.append("};")
    lines.append("")
    lines.append("static const uint32_t *const rgb_image_test_inputs[RGB_IMAGE_TEST_COUNT] = {")
    lines.extend(f"    rgb_test_{idx}_input," for idx in range(len(prepared)))
    lines.append("};")
    lines.append("")
    lines.append("static const rgb_fft_probe_t *const rgb_image_test_probes[RGB_IMAGE_TEST_COUNT] = {")
    lines.extend(f"    rgb_test_{idx}_probes," for idx in range(len(prepared)))
    lines.append("};")
    lines.append("")
    lines.append("#endif")
    lines.append("")

    header_path.parent.mkdir(parents=True, exist_ok=True)
    header_path.write_text("\n".join(lines), encoding="utf-8")
    (out_dir / "manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    parser.add_argument("--header", type=Path, default=Path("vitis/fft_dump_app/src/rgb_image_fft_tests.h"))
    parser.add_argument("--out", type=Path, default=Path("data/demo_fft_tests"))
    args = parser.parse_args()

    repo_root = args.repo_root.resolve()
    images = [
        ("synthetic_checker", make_checker()),
    ]
    build_header(images, repo_root / args.header, repo_root / args.out)
    print("Generated Vitis demo tests:")
    for name, _arr in images:
        print(f"  - {name}")
    print(f"Header: {repo_root / args.header}")
    print(f"Demo assets: {repo_root / args.out}")


if __name__ == "__main__":
    main()
