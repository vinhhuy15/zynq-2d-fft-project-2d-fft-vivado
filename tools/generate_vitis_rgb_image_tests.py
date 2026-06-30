from pathlib import Path
import argparse
import pickle
import re
import shutil

import numpy as np
from PIL import Image


FFT_SIZE = 64
FRAC_BITS = 12
FIXED_SCALE = 1 << FRAC_BITS
CHANNELS = ("r", "g", "b")
PROBE_BINS = (0, 1, 2, 3, 7, 8, 15, 16, 31, 32, 63, 64, 65, 127, 255, 511, 1023, 2047, 4095)


def sanitize_name(name: str) -> str:
    name = re.sub(r"[^a-zA-Z0-9_]+", "_", name.strip().lower())
    return name.strip("_") or "image"


def load_cifar_batch(path: Path, count: int) -> list[tuple[str, np.ndarray]]:
    with path.open("rb") as f:
        batch = pickle.load(f, encoding="latin1")

    data = batch["data"].reshape(-1, 3, 32, 32)
    labels = batch.get("labels", list(range(data.shape[0])))
    names = []
    for idx in range(min(count, data.shape[0])):
        arr = np.transpose(data[idx], (1, 2, 0)).astype(np.uint8)
        names.append((f"cifar_{idx:02d}_label_{labels[idx]}", arr))
    return names


def load_project_fallback_images(root: Path, count: int) -> list[tuple[str, np.ndarray]]:
    input_dir = root / "software" / "python_reference" / "zynq_2d_fft_python_reference" / "data" / "input"
    preferred = ["checker_64x64.png", "gradient_64x64.png", "circle_64x64.png", "square_64x64.png"]
    images = []
    for filename in preferred:
        path = input_dir / filename
        if path.exists():
            images.append((f"project_{path.stem}", np.asarray(Image.open(path).convert("RGB"), dtype=np.uint8)))
        if len(images) >= count:
            break
    return images


def load_image_tree(root: Path, count: int) -> list[tuple[str, np.ndarray]]:
    image_paths = sorted(
        p for p in root.rglob("*")
        if p.is_file() and p.suffix.lower() in {".png", ".jpg", ".jpeg", ".bmp", ".ppm"}
    )
    if not image_paths:
        return []

    selected = []
    seen_classes = set()
    for path in image_paths:
        class_name = path.parent.name
        if class_name in seen_classes:
            continue
        selected.append(path)
        seen_classes.add(class_name)
        if len(selected) >= count:
            break

    if len(selected) < count:
        for path in image_paths:
            if path in selected:
                continue
            selected.append(path)
            if len(selected) >= count:
                break

    images = []
    for path in selected:
        stem = f"{path.parent.name}_{path.stem}"
        images.append((stem, np.asarray(Image.open(path).convert("RGB"), dtype=np.uint8)))
    return images


def resize_to_fft(arr: np.ndarray) -> np.ndarray:
    img = Image.fromarray(arr.astype(np.uint8), mode="RGB")
    img = img.resize((FFT_SIZE, FFT_SIZE), Image.Resampling.BILINEAR)
    return np.asarray(img, dtype=np.uint8)


def to_fixed_q12(arr_u8: np.ndarray) -> np.ndarray:
    normalized = arr_u8.astype(np.float64) / 255.0
    return np.rint(normalized * FIXED_SCALE).astype(np.int32)


def raw_to_c_literal(value: int) -> str:
    return f"0x{np.uint32(value).item():08x}U"


def save_visuals(name: str, arr_u8: np.ndarray, out_dir: Path) -> None:
    image_dir = out_dir / "input"
    visual_dir = out_dir / "visual"
    recon_dir = out_dir / "reconstructed"
    image_dir.mkdir(parents=True, exist_ok=True)
    visual_dir.mkdir(parents=True, exist_ok=True)
    recon_dir.mkdir(parents=True, exist_ok=True)

    Image.fromarray(arr_u8, mode="RGB").save(image_dir / f"{name}_64x64.png")

    reconstructed = np.zeros_like(arr_u8, dtype=np.uint8)
    fixed = to_fixed_q12(arr_u8).astype(np.float64) / FIXED_SCALE
    for ch_idx, ch_name in enumerate(CHANNELS):
        fft = np.fft.fft2(fixed[:, :, ch_idx])
        shifted = np.fft.fftshift(fft)
        mag = np.log1p(np.abs(shifted))
        if mag.max() > mag.min():
            mag_u8 = np.rint((mag - mag.min()) * 255.0 / (mag.max() - mag.min())).astype(np.uint8)
        else:
            mag_u8 = np.zeros((FFT_SIZE, FFT_SIZE), dtype=np.uint8)
        Image.fromarray(mag_u8, mode="L").save(visual_dir / f"{name}_{ch_name}_fft_log_magnitude_shifted.png")

        inv = np.real(np.fft.ifft2(fft))
        reconstructed[:, :, ch_idx] = np.clip(np.rint(inv * 255.0), 0, 255).astype(np.uint8)

    Image.fromarray(reconstructed, mode="RGB").save(recon_dir / f"{name}_ifft_reconstructed.png")


def build_header(images: list[tuple[str, np.ndarray]], header_path: Path, out_dir: Path) -> None:
    if out_dir.exists():
        shutil.rmtree(out_dir)

    prepared = []
    for raw_name, raw_arr in images:
        name = sanitize_name(raw_name)
        arr_u8 = resize_to_fft(raw_arr)
        fixed_raw = to_fixed_q12(arr_u8)
        save_visuals(name, arr_u8, out_dir)

        channel_major = np.transpose(fixed_raw, (2, 0, 1)).reshape(-1)
        probes = []
        fixed_value = fixed_raw.astype(np.float64) / FIXED_SCALE
        for ch_idx in range(3):
            fft = np.fft.fft2(fixed_value[:, :, ch_idx]).reshape(-1)
            for bin_idx in PROBE_BINS:
                real_raw = int(np.rint(np.real(fft[bin_idx]) * FIXED_SCALE))
                imag_raw = int(np.rint(np.imag(fft[bin_idx]) * FIXED_SCALE))
                probes.append((ch_idx, bin_idx, np.int32(real_raw).item(), np.int32(imag_raw).item()))

        prepared.append((name, channel_major.astype(np.uint32), probes))

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

    for idx, (name, samples, probes) in enumerate(prepared):
        lines.append(f"static const uint32_t rgb_test_{idx}_input[RGB_IMAGE_TEST_SAMPLES] = {{")
        for start in range(0, len(samples), 8):
            chunk = ", ".join(raw_to_c_literal(int(v)) for v in samples[start:start + 8])
            lines.append(f"    {chunk},")
        lines.append("};")
        lines.append("")
        lines.append(f"static const rgb_fft_probe_t rgb_test_{idx}_probes[RGB_IMAGE_TEST_PROBE_COUNT] = {{")
        for ch, bin_idx, real_raw, imag_raw in probes:
            lines.append(f"    {{{ch}U, {bin_idx}U, {real_raw}, {imag_raw}}},")
        lines.append("};")
        lines.append("")

    lines.append("static const char *const rgb_image_test_names[RGB_IMAGE_TEST_COUNT] = {")
    for idx, (name, _, _) in enumerate(prepared):
        comma = "," if idx + 1 < len(prepared) else ""
        lines.append(f'    "{name}"{comma}')
    lines.append("};")
    lines.append("")

    lines.append("static const uint32_t *const rgb_image_test_inputs[RGB_IMAGE_TEST_COUNT] = {")
    for idx in range(len(prepared)):
        comma = "," if idx + 1 < len(prepared) else ""
        lines.append(f"    rgb_test_{idx}_input{comma}")
    lines.append("};")
    lines.append("")

    lines.append("static const rgb_fft_probe_t *const rgb_image_test_probes[RGB_IMAGE_TEST_COUNT] = {")
    for idx in range(len(prepared)):
        comma = "," if idx + 1 < len(prepared) else ""
        lines.append(f"    rgb_test_{idx}_probes{comma}")
    lines.append("};")
    lines.append("")
    lines.append("#endif")
    lines.append("")

    header_path.parent.mkdir(parents=True, exist_ok=True)
    header_path.write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    parser.add_argument("--cifar-batch", type=Path, default=None,
                        help="Path to CIFAR-10 python batch, for example data/cifar-10-batches-py/test_batch.")
    parser.add_argument("--image-root", type=Path, default=None,
                        help="Directory containing image files, optionally grouped in class subdirectories.")
    parser.add_argument("--count", type=int, default=3)
    parser.add_argument("--header", type=Path, default=Path("vitis/fft_app/src/rgb_image_fft_tests.h"))
    parser.add_argument("--out", type=Path, default=Path("data/rgb_image_fft_tests"))
    args = parser.parse_args()

    repo_root = args.repo_root.resolve()
    image_root = args.image_root
    if image_root is not None and not image_root.is_absolute():
        image_root = repo_root / image_root

    cifar_batch = args.cifar_batch
    if cifar_batch is not None and not cifar_batch.is_absolute():
        cifar_batch = repo_root / cifar_batch
    if cifar_batch is None:
        candidate = repo_root / "data" / "cifar-10-batches-py" / "test_batch"
        cifar_batch = candidate if candidate.exists() else None

    if image_root is not None and image_root.exists():
        images = load_image_tree(image_root, args.count)
        source = f"image tree: {image_root}"
    elif cifar_batch is not None and cifar_batch.exists():
        images = load_cifar_batch(cifar_batch, args.count)
        source = f"CIFAR-10 batch: {cifar_batch}"
    else:
        images = load_project_fallback_images(repo_root, args.count)
        source = "project fallback images; no CIFAR-10 batch found"

    if not images:
        raise SystemExit("No input images found.")

    header_path = (repo_root / args.header).resolve()
    out_dir = (repo_root / args.out).resolve()
    build_header(images, header_path, out_dir)

    print(f"Generated {len(images)} RGB FFT image tests from {source}")
    print(f"Header: {header_path}")
    print(f"Visuals: {out_dir}")


if __name__ == "__main__":
    main()
