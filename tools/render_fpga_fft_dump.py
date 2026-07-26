from pathlib import Path
import argparse
import json
import re

import numpy as np
from PIL import Image, ImageChops, ImageDraw


CHANNELS = ("r", "g", "b")
FIXED_SCALE = 4096.0
NAME_ALIASES = {
    "synthetic_checker": "checker_64x64",
    "synthetic_gradient": "gradient_64x64",
}


def signed_u32(hex_text: str) -> int:
    value = int(hex_text, 16) & 0xFFFFFFFF
    if value & 0x80000000:
        value -= 0x100000000
    return value


def log_magnitude_image(fft_complex: np.ndarray) -> np.ndarray:
    shifted = np.fft.fftshift(fft_complex)
    mag = np.log1p(np.abs(shifted))
    if float(mag.max()) <= float(mag.min()):
        return np.zeros(mag.shape, dtype=np.uint8)
    return np.rint((mag - mag.min()) * 255.0 / (mag.max() - mag.min())).astype(np.uint8)


def reference_stem(name: str) -> str:
    return NAME_ALIASES.get(name, name)


def python_fft_from_input(input_path: Path) -> list[Image.Image]:
    image = Image.open(input_path).convert("RGB").resize((64, 64), Image.Resampling.BILINEAR)
    arr = np.asarray(image, dtype=np.float64)
    fixed = np.rint((arr / 255.0) * FIXED_SCALE) / FIXED_SCALE

    rendered = []
    for ch_idx in range(3):
        fft_complex = np.fft.fft2(fixed[:, :, ch_idx])
        rendered.append(Image.fromarray(log_magnitude_image(fft_complex), mode="L"))
    return rendered


def image_mae(a: Image.Image, b: Image.Image) -> float:
    arr_a = np.asarray(a.convert("L"), dtype=np.float64)
    arr_b = np.asarray(b.convert("L"), dtype=np.float64)
    return float(np.mean(np.abs(arr_a - arr_b)))


def parse_uart_log(log_path: Path) -> list[dict]:
    begin_re = re.compile(r"FFT_DUMP_BEGIN,([^,]+),(\d+),(\d+),(\d+)")
    data_re = re.compile(r"D,(\d+),(\d+),([0-9a-fA-F]{8}),([0-9a-fA-F]{8})")
    end_re = re.compile(r"FFT_DUMP_END,([^,\s]+)")

    dumps = []
    current = None

    for raw_line in log_path.read_text(encoding="utf-8", errors="ignore").splitlines():
        line = raw_line.strip()
        begin = begin_re.search(line)
        if begin:
            name, width, height, channels = begin.groups()
            width_i = int(width)
            height_i = int(height)
            channels_i = int(channels)
            current = {
                "name": name,
                "width": width_i,
                "height": height_i,
                "channels": channels_i,
                "real": np.zeros((channels_i, height_i * width_i), dtype=np.float64),
                "imag": np.zeros((channels_i, height_i * width_i), dtype=np.float64),
                "count": 0,
            }
            continue

        if current is not None:
            data = data_re.search(line)
            if data:
                ch, bin_idx, real_hex, imag_hex = data.groups()
                ch_i = int(ch)
                bin_i = int(bin_idx)
                if ch_i < current["channels"] and bin_i < current["width"] * current["height"]:
                    current["real"][ch_i, bin_i] = signed_u32(real_hex) / FIXED_SCALE
                    current["imag"][ch_i, bin_i] = signed_u32(imag_hex) / FIXED_SCALE
                    current["count"] += 1
                continue

            end = end_re.search(line)
            if end:
                dumps.append(current)
                current = None

    return dumps


def make_contact_sheet(title: str, images: list[tuple[str, Image.Image]], path: Path) -> None:
    tile_w, tile_h = 220, 190
    sheet = Image.new("RGB", (tile_w * len(images), tile_h), "white")
    draw = ImageDraw.Draw(sheet)
    for idx, (label, image) in enumerate(images):
        rgb = image.convert("RGB")
        rgb.thumbnail((180, 150), Image.Resampling.NEAREST)
        x = idx * tile_w + (tile_w - rgb.width) // 2
        y = 20
        sheet.paste(rgb, (x, y))
        draw.text((idx * tile_w + 12, 170), label, fill="black")
    draw.text((12, 2), title, fill="black")
    sheet.save(path)


def render_dump(dump: dict, out_dir: Path, python_ref_dir: Path | None, input_dir: Path | None) -> dict:
    name = dump["name"]
    stem = reference_stem(name)
    width = dump["width"]
    height = dump["height"]
    real = dump["real"]
    imag = dump["imag"]

    hw_dir = out_dir / "hardware_fft"
    py_dir = out_dir / "python_reference_fft"
    compare_dir = out_dir / "comparison"
    hw_dir.mkdir(parents=True, exist_ok=True)
    py_dir.mkdir(parents=True, exist_ok=True)
    compare_dir.mkdir(parents=True, exist_ok=True)

    hw_channel_images = []
    for ch_idx, ch_name in enumerate(CHANNELS[: dump["channels"]]):
        fft_complex = (real[ch_idx] + 1j * imag[ch_idx]).reshape(height, width)
        rendered = Image.fromarray(log_magnitude_image(fft_complex), mode="L")
        hw_path = hw_dir / f"{name}_{ch_name}_fft_fpga.png"
        rendered.save(hw_path)
        hw_channel_images.append(rendered)

    if len(hw_channel_images) >= 3:
        Image.merge("RGB", hw_channel_images[:3]).save(hw_dir / f"{name}_rgb_fft_fpga.png")

    python_channel_images = None
    input_img = None
    if input_dir is not None:
        input_path = input_dir / f"{stem}.png"
        if input_path.exists():
            input_img = Image.open(input_path).convert("RGB")
            python_channel_images = python_fft_from_input(input_path)
            for ch_idx, ch_name in enumerate(CHANNELS[: dump["channels"]]):
                python_channel_images[ch_idx].save(py_dir / f"{name}_{ch_name}_fft_python.png")

    comparisons = []
    metrics = []
    for ch_idx, ch_name in enumerate(CHANNELS[: dump["channels"]]):
        hw_img = hw_channel_images[ch_idx]
        py_img = None
        if python_channel_images is not None:
            py_img = python_channel_images[ch_idx]
        elif python_ref_dir is not None:
            candidate = python_ref_dir / f"{name}_{ch_name}_fft_python.png"
            if candidate.exists():
                py_img = Image.open(candidate).convert("L")

        if py_img is not None:
            diff = ImageChops.difference(py_img, hw_img)
            parts = []
            if input_img is not None:
                parts.append(("Input", input_img))
            parts.extend([("Python FFT", py_img), ("FPGA FFT", hw_img), ("Abs diff", diff)])
            sheet_path = compare_dir / f"{name}_{ch_name}_comparison.png"
            make_contact_sheet(f"{name} channel {ch_name.upper()}", parts, sheet_path)
            comparisons.append(str(sheet_path))
            metrics.append({
                "channel": ch_name,
                "image_mae_0_255": image_mae(py_img, hw_img),
                "image_max_abs_0_255": int(np.max(np.asarray(diff, dtype=np.uint8))),
            })

    return {
        "name": name,
        "reference_stem": stem,
        "width": width,
        "height": height,
        "channels": dump["channels"],
        "samples_read": dump["count"],
        "expected_samples": width * height * dump["channels"],
        "hardware_fft_dir": str(hw_dir),
        "python_reference_fft_dir": str(py_dir),
        "comparison_files": comparisons,
        "comparison_metrics": metrics,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--log", type=Path, required=True, help="UART log captured from COM4.")
    parser.add_argument("--out", type=Path, default=Path("data/fpga_fft_from_uart"))
    parser.add_argument("--python-ref-dir", type=Path, default=Path("data/demo_fft_tests/python_reference_fft"))
    parser.add_argument(
        "--input-dir",
        type=Path,
        default=Path("software/python_reference/zynq_2d_fft_python_reference/data/input"),
    )
    args = parser.parse_args()

    dumps = parse_uart_log(args.log)
    if not dumps:
        raise SystemExit("No FFT_DUMP_BEGIN/FFT_DUMP_END blocks found in the UART log.")

    args.out.mkdir(parents=True, exist_ok=True)
    summaries = [
        render_dump(
            dump,
            args.out,
            args.python_ref_dir if args.python_ref_dir.exists() else None,
            args.input_dir if args.input_dir.exists() else None,
        )
        for dump in dumps
    ]

    summary_path = args.out / "summary.json"
    summary_path.write_text(json.dumps(summaries, indent=2), encoding="utf-8")

    print(f"Rendered {len(summaries)} FPGA FFT dump(s).")
    print(f"Output: {args.out}")
    print(f"Summary: {summary_path}")


if __name__ == "__main__":
    main()
