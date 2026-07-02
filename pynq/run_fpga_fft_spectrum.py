#!/usr/bin/env python3
"""
Run the RGB 2D FFT accelerator on a PYNQ/Zynq board and render FPGA spectra.

Default behavior reproduces the synthetic checker image used in Fig. 10:

    sudo python3 run_fpga_fft_spectrum.py --bit design.bit --out fpga_fft_spectrum

If the bitstream is already loaded, pass the AXI-Lite base address instead:

    sudo python3 run_fpga_fft_spectrum.py --base-addr 0x40000000 --out fpga_fft_spectrum

Outputs:
  - input image used for the run
  - FPGA log-magnitude spectra for R/G/B
  - Python reference spectra computed from the same quantized input
  - comparison sheets and raw real/imag dumps
"""

import argparse
import json
import time
from pathlib import Path

import numpy as np
from PIL import Image, ImageChops, ImageDraw

try:
    from pynq import MMIO, Overlay, allocate
except ImportError as exc:
    raise SystemExit(
        "This script must run on the PYNQ board Python environment. "
        "Missing module: %s" % exc
    )


FFT_SIZE = 64
CHANNELS = ("r", "g", "b")
CHANNEL_LABELS = ("R", "G", "B")
FRAC_BITS = 12
FIXED_SCALE = 1 << FRAC_BITS
TOTAL_SAMPLES = 3 * FFT_SIZE * FFT_SIZE

AP_CTRL = 0x00
INPUT_PTR = 0x10
OUTPUT_REAL_PTR = 0x1C
OUTPUT_IMAG_PTR = 0x28
AP_START = 0x01
AP_DONE = 0x02


def make_checker():
    yy, xx = np.indices((FFT_SIZE, FFT_SIZE))
    block = 8
    checker = (((xx // block) + (yy // block)) % 2).astype(np.uint8)
    arr = np.zeros((FFT_SIZE, FFT_SIZE, 3), dtype=np.uint8)
    arr[:, :, 0] = checker * 255
    arr[:, :, 1] = (1 - checker) * 255
    arr[:, :, 2] = ((xx // block) % 2).astype(np.uint8) * 255
    return arr


def load_rgb_image(path):
    image = Image.open(path).convert("RGB").resize((FFT_SIZE, FFT_SIZE), Image.NEAREST)
    return np.asarray(image, dtype=np.uint8)


def to_fixed_q12(arr_u8):
    normalized = arr_u8.astype(np.float64) / 255.0
    return np.rint(normalized * FIXED_SCALE).astype(np.int32)


def raw_u32_to_float(raw):
    return raw.astype(np.uint32).view(np.int32).astype(np.float64) / float(FIXED_SCALE)


def log_magnitude_image(fft_complex):
    shifted = np.fft.fftshift(fft_complex)
    mag = np.log1p(np.abs(shifted))
    if float(mag.max()) <= float(mag.min()):
        return np.zeros(mag.shape, dtype=np.uint8)
    scaled = (mag - mag.min()) * 255.0 / (mag.max() - mag.min())
    return np.rint(scaled).astype(np.uint8)


def save_gray(path, arr):
    Image.fromarray(arr.astype(np.uint8), mode="L").save(path)


def save_rgb(path, channels):
    Image.merge("RGB", [Image.fromarray(ch.astype(np.uint8), mode="L") for ch in channels]).save(path)


def thumbnail(image, max_size=(150, 150)):
    img = image.convert("RGB")
    img.thumbnail(max_size, Image.NEAREST)
    return img


def make_contact_sheet(path, title, items):
    tile_w, tile_h = 210, 190
    sheet = Image.new("RGB", (tile_w * len(items), tile_h), "white")
    draw = ImageDraw.Draw(sheet)
    draw.text((10, 4), title, fill="black")

    for idx, (label, image) in enumerate(items):
        img = thumbnail(image)
        x0 = idx * tile_w + (tile_w - img.width) // 2
        y0 = 28
        sheet.paste(img, (x0, y0))
        draw.text((idx * tile_w + 10, 165), label, fill="black")

    sheet.save(path)


def find_fft_ip_base(overlay, requested_ip):
    ip_dict = overlay.ip_dict
    if requested_ip:
        if requested_ip not in ip_dict:
            raise RuntimeError("IP %r not found. Available IPs: %s" % (requested_ip, sorted(ip_dict)))
        return int(ip_dict[requested_ip]["phys_addr"]), requested_ip

    candidates = [name for name in ip_dict if "fft2d_fixed_top" in name.lower()]
    if not candidates:
        candidates = [name for name in ip_dict if "fft" in name.lower()]
    if not candidates:
        raise RuntimeError("Cannot find FFT IP in overlay. Available IPs: %s" % sorted(ip_dict))

    name = sorted(candidates)[0]
    return int(ip_dict[name]["phys_addr"]), name


def write_ptr64(mmio, offset, physical_address):
    mmio.write(offset, int(physical_address) & 0xFFFFFFFF)
    mmio.write(offset + 4, (int(physical_address) >> 32) & 0xFFFFFFFF)


def run_accelerator(mmio, in_buf, out_real, out_imag, timeout_s):
    in_buf.flush()
    out_real.flush()
    out_imag.flush()

    write_ptr64(mmio, INPUT_PTR, in_buf.physical_address)
    write_ptr64(mmio, OUTPUT_REAL_PTR, out_real.physical_address)
    write_ptr64(mmio, OUTPUT_IMAG_PTR, out_imag.physical_address)

    start = time.time()
    mmio.write(AP_CTRL, AP_START)
    while (mmio.read(AP_CTRL) & AP_DONE) == 0:
        if time.time() - start > timeout_s:
            raise TimeoutError("FFT IP timeout. AP_CTRL=0x%08x" % mmio.read(AP_CTRL))
        time.sleep(0.001)

    out_real.invalidate()
    out_imag.invalidate()
    return time.time() - start


def render_outputs(arr_u8, out_real_raw, out_imag_raw, out_dir, name):
    out_dir.mkdir(parents=True, exist_ok=True)
    fpga_dir = out_dir / "fpga_fft"
    py_dir = out_dir / "python_reference_fft"
    cmp_dir = out_dir / "comparison"
    raw_dir = out_dir / "raw"
    for directory in (fpga_dir, py_dir, cmp_dir, raw_dir):
        directory.mkdir(parents=True, exist_ok=True)

    Image.fromarray(arr_u8, mode="RGB").save(out_dir / ("%s_input_64x64.png" % name))

    fixed = to_fixed_q12(arr_u8)
    fixed_float = fixed.astype(np.float64) / float(FIXED_SCALE)
    real_float = raw_u32_to_float(out_real_raw.copy()).reshape(3, FFT_SIZE, FFT_SIZE)
    imag_float = raw_u32_to_float(out_imag_raw.copy()).reshape(3, FFT_SIZE, FFT_SIZE)

    py_imgs = []
    fpga_imgs = []
    max_abs_real = []
    max_abs_imag = []

    for ch_idx, ch_name in enumerate(CHANNELS):
        py_fft = np.fft.fft2(fixed_float[:, :, ch_idx])
        fpga_fft = real_float[ch_idx] + 1j * imag_float[ch_idx]

        py_img = log_magnitude_image(py_fft)
        fpga_img = log_magnitude_image(fpga_fft)
        py_imgs.append(py_img)
        fpga_imgs.append(fpga_img)

        save_gray(py_dir / ("%s_%s_fft_python.png" % (name, ch_name)), py_img)
        save_gray(fpga_dir / ("%s_%s_fft_fpga.png" % (name, ch_name)), fpga_img)

        py_real_raw = np.rint(np.real(py_fft) * FIXED_SCALE).astype(np.int64)
        py_imag_raw = np.rint(np.imag(py_fft) * FIXED_SCALE).astype(np.int64)
        got_real_raw = out_real_raw[ch_idx].astype(np.uint32).view(np.int32).astype(np.int64)
        got_imag_raw = out_imag_raw[ch_idx].astype(np.uint32).view(np.int32).astype(np.int64)
        max_abs_real.append(int(np.max(np.abs(got_real_raw - py_real_raw))))
        max_abs_imag.append(int(np.max(np.abs(got_imag_raw - py_imag_raw))))

        diff = ImageChops.difference(
            Image.fromarray(py_img, mode="L"),
            Image.fromarray(fpga_img, mode="L"),
        )
        make_contact_sheet(
            cmp_dir / ("%s_%s_comparison.png" % (name, ch_name)),
            "%s channel %s" % (name, CHANNEL_LABELS[ch_idx]),
            [
                ("Input", Image.fromarray(arr_u8, mode="RGB")),
                ("Python", Image.fromarray(py_img, mode="L")),
                ("FPGA", Image.fromarray(fpga_img, mode="L")),
                ("Abs diff", diff),
            ],
        )

    save_rgb(py_dir / ("%s_rgb_fft_python.png" % name), py_imgs)
    save_rgb(fpga_dir / ("%s_rgb_fft_fpga.png" % name), fpga_imgs)

    py_rgb = Image.open(py_dir / ("%s_rgb_fft_python.png" % name))
    fpga_rgb = Image.open(fpga_dir / ("%s_rgb_fft_fpga.png" % name))
    diff_rgb = ImageChops.difference(py_rgb, fpga_rgb)
    diff_rgb.save(cmp_dir / ("%s_rgb_rendered_absdiff.png" % name))
    make_contact_sheet(
        cmp_dir / ("%s_rgb_comparison.png" % name),
        "%s RGB FFT visual comparison" % name,
        [
            ("Input", Image.fromarray(arr_u8, mode="RGB")),
            ("Python RGB", py_rgb),
            ("FPGA RGB", fpga_rgb),
            ("Rendered diff", diff_rgb),
        ],
    )

    np.savez_compressed(
        raw_dir / ("%s_fpga_fft_raw_q12.npz" % name),
        input_u8=arr_u8,
        output_real_u32=out_real_raw,
        output_imag_u32=out_imag_raw,
        output_real_float=real_float,
        output_imag_float=imag_float,
    )

    return {
        "name": name,
        "fixed_point": "Q20.12 stored in 32-bit signed words",
        "max_abs_error_raw_vs_python": {
            CHANNEL_LABELS[i]: {"real": max_abs_real[i], "imag": max_abs_imag[i]}
            for i in range(3)
        },
        "files": {
            "input": str(out_dir / ("%s_input_64x64.png" % name)),
            "fpga_rgb": str(fpga_dir / ("%s_rgb_fft_fpga.png" % name)),
            "python_rgb": str(py_dir / ("%s_rgb_fft_python.png" % name)),
            "comparison": str(cmp_dir / ("%s_rgb_comparison.png" % name)),
            "raw_npz": str(raw_dir / ("%s_fpga_fft_raw_q12.npz" % name)),
        },
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--bit", type=Path, help="Optional bitstream to load before running.")
    parser.add_argument("--ip", help="Overlay IP name. Auto-detected when omitted.")
    parser.add_argument("--base-addr", type=lambda x: int(x, 0), default=None,
                        help="AXI-Lite base address if no bitstream is loaded.")
    parser.add_argument("--image", type=Path, help="Optional RGB image. Resized to 64x64.")
    parser.add_argument("--name", default="synthetic_checker", help="Output filename prefix.")
    parser.add_argument("--out", type=Path, default=Path("fpga_fft_spectrum"),
                        help="Output directory on the board.")
    parser.add_argument("--timeout", type=float, default=10.0, help="IP timeout in seconds.")
    args = parser.parse_args()

    overlay = None
    ip_name = None
    if args.bit is not None:
        overlay = Overlay(str(args.bit))
        base_addr, ip_name = find_fft_ip_base(overlay, args.ip)
    elif args.base_addr is not None:
        base_addr = args.base_addr
    else:
        base_addr = 0x40000000

    mmio = MMIO(base_addr, 0x1000)
    arr_u8 = load_rgb_image(args.image) if args.image else make_checker()
    fixed_raw = to_fixed_q12(arr_u8)
    channel_major = np.transpose(fixed_raw, (2, 0, 1)).reshape(TOTAL_SAMPLES)

    in_buf = allocate(shape=(TOTAL_SAMPLES,), dtype=np.uint32)
    out_real = allocate(shape=(TOTAL_SAMPLES,), dtype=np.uint32)
    out_imag = allocate(shape=(TOTAL_SAMPLES,), dtype=np.uint32)

    try:
        in_buf[:] = channel_major.astype(np.uint32)
        out_real[:] = np.uint32(0xDEADBEEF)
        out_imag[:] = np.uint32(0xA5A5A5A5)

        elapsed_s = run_accelerator(mmio, in_buf, out_real, out_imag, args.timeout)
        out_real_raw = np.asarray(out_real, dtype=np.uint32).copy().reshape(3, FFT_SIZE, FFT_SIZE)
        out_imag_raw = np.asarray(out_imag, dtype=np.uint32).copy().reshape(3, FFT_SIZE, FFT_SIZE)

        if np.all(out_real_raw.reshape(-1) == np.uint32(0xDEADBEEF)):
            raise RuntimeError("Output real buffer still contains sentinel values.")

        summary = render_outputs(arr_u8, out_real_raw, out_imag_raw, args.out, args.name)
        summary["elapsed_seconds"] = elapsed_s
        summary["axi_lite_base_addr"] = "0x%08x" % base_addr
        if ip_name:
            summary["ip_name"] = ip_name
        summary_path = args.out / "summary.json"
        summary_path.write_text(json.dumps(summary, indent=2), encoding="utf-8")

        print("FPGA FFT spectrum render complete.")
        print("AXI-Lite base: 0x%08x" % base_addr)
        if ip_name:
            print("IP: %s" % ip_name)
        print("Elapsed: %.6f s" % elapsed_s)
        print("Output: %s" % args.out)
        print("Comparison sheet: %s" % summary["files"]["comparison"])
        print("Summary: %s" % summary_path)
    finally:
        in_buf.freebuffer()
        out_real.freebuffer()
        out_imag.freebuffer()


if __name__ == "__main__":
    main()
