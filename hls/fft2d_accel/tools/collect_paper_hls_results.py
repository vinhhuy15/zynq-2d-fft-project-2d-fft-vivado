#!/usr/bin/env python3
"""Collect HLS reports into paper-ready tables and a Figure 6 replacement."""

from __future__ import annotations

import argparse
import csv
import math
import re
import xml.etree.ElementTree as ET
from pathlib import Path


RESOURCE_KEYS = ("BRAM_18K", "DSP", "FF", "LUT")
FORMATS = [(32, 20), (28, 20), (24, 20), (22, 20), (24, 16), (24, 12), (20, 12)]
CHANNEL_RE = re.compile(
    r"Channel\s+([rgb])\s+(Real|Imag)\s+MAE:\s*([0-9.eE+-]+).*?MaxAbs:\s*([0-9.eE+-]+)"
)
TOLERANCE_RE = re.compile(r"Pass tolerance MaxAbs <=\s*([0-9.eE+-]+)")


def clean_int(text: str | None) -> int | None:
    if text is None:
        return None
    text = text.strip()
    if not text or text.upper() == "N/A":
        return None
    try:
        return int(float(text))
    except ValueError:
        return None


def parse_resources(xml_path: Path) -> dict[str, int | None]:
    empty = {key: None for key in RESOURCE_KEYS}
    if not xml_path.exists():
        return empty

    root = ET.parse(xml_path).getroot()
    for node in root.iter():
        values = {child.tag: clean_int(child.text) for child in list(node)}
        if all(key in values for key in RESOURCE_KEYS):
            return {key: values.get(key) for key in RESOURCE_KEYS}
    return empty


def parse_csim_log(log_path: Path) -> dict[str, object]:
    text = log_path.read_text(encoding="utf-8", errors="ignore")
    tolerance_match = TOLERANCE_RE.search(text)
    tolerance = float(tolerance_match.group(1)) if tolerance_match else 1024.0

    real_max = 0.0
    imag_max = 0.0
    real_mae = []
    imag_mae = []

    for match in CHANNEL_RE.finditer(text):
        kind = match.group(2)
        mae = float(match.group(3))
        max_abs = float(match.group(4))
        if kind == "Real":
            real_mae.append(mae)
            real_max = max(real_max, max_abs)
        else:
            imag_mae.append(mae)
            imag_max = max(imag_max, max_abs)

    has_all_channels = len(real_mae) == 3 and len(imag_mae) == 3
    pass_by_error = real_max <= tolerance and imag_max <= tolerance
    pass_by_exit = "CSim done with 0 errors" in text

    return {
        "real_max": real_max if has_all_channels else math.nan,
        "imag_max": imag_max if has_all_channels else math.nan,
        "real_mae": sum(real_mae) / len(real_mae) if real_mae else math.nan,
        "imag_mae": sum(imag_mae) / len(imag_mae) if imag_mae else math.nan,
        "pass": has_all_channels and pass_by_error and pass_by_exit,
        "tolerance": tolerance,
    }


def format_value(value: object, digits: int = 4) -> str:
    if value is None:
        return "-"
    if isinstance(value, float):
        if math.isnan(value):
            return "-"
        return f"{value:.{digits}f}"
    return str(value)


def percent_reduction(before: int | None, after: int | None) -> float | None:
    if before in (None, 0) or after is None:
        return None
    return (before - after) * 100.0 / before


def collect_twiddle(results_dir: Path) -> list[dict[str, object]]:
    variants = [
        ("Runtime sin/cos", "runtime_trig_28_20_csynth.xml"),
        ("Twiddle LUT", "twiddle_lut_28_20_csynth.xml"),
    ]
    rows = []
    for label, xml_name in variants:
        resources = parse_resources(results_dir / xml_name)
        row: dict[str, object] = {"Variant": label}
        row.update(resources)
        rows.append(row)

    if len(rows) == 2:
        reduction: dict[str, object] = {"Variant": "Reduction (%)"}
        for key in RESOURCE_KEYS:
            reduction[key] = percent_reduction(rows[0].get(key), rows[1].get(key))
        rows.append(reduction)
    return rows


def collect_bitwidth(results_dir: Path) -> list[dict[str, object]]:
    rows = []
    for total_bits, integer_bits in FORMATS:
        sample_logs = sorted(results_dir.glob(f"*_{total_bits}_{integer_bits}_csim.log"))
        sample_results = [parse_csim_log(path) for path in sample_logs]
        passed = sum(1 for item in sample_results if item["pass"])
        total = len(sample_results)

        real_values = [item["real_max"] for item in sample_results if not math.isnan(item["real_max"])]
        imag_values = [item["imag_max"] for item in sample_results if not math.isnan(item["imag_max"])]
        resources = parse_resources(results_dir / f"bitwidth_{total_bits}_{integer_bits}_csynth.xml")

        row: dict[str, object] = {
            "Format": f"ap_fixed<{total_bits},{integer_bits}>",
            "TotalBits": total_bits,
            "IntegerBits": integer_bits,
            "PassedSamples": passed,
            "TotalSamples": total,
            "WorstRealMaxAbs": max(real_values) if real_values else math.nan,
            "WorstImagMaxAbs": max(imag_values) if imag_values else math.nan,
            "Status": "PASS" if total > 0 and passed == total else "FAIL",
        }
        row.update(resources)
        rows.append(row)
    return rows


def write_csv(path: Path, rows: list[dict[str, object]], fields: list[str]) -> None:
    with path.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.DictWriter(fh, fieldnames=fields)
        writer.writeheader()
        for row in rows:
            writer.writerow({field: row.get(field, "") for field in fields})


def write_twiddle_svg(path: Path, rows: list[dict[str, object]]) -> None:
    if len(rows) < 2:
        path.write_text("<svg xmlns='http://www.w3.org/2000/svg' width='880' height='420'></svg>\n", encoding="utf-8")
        return

    runtime = rows[0]
    lut = rows[1]
    max_by_metric = {key: max(float(runtime.get(key) or 0), float(lut.get(key) or 0), 1.0) for key in RESOURCE_KEYS}
    width = 880
    height = 420
    left = 70
    bottom = 350
    chart_h = 260
    group_w = 190
    bar_w = 42

    parts = [
        f"<svg xmlns='http://www.w3.org/2000/svg' width='{width}' height='{height}' viewBox='0 0 {width} {height}'>",
        "<rect width='100%' height='100%' fill='white'/>",
        "<text x='440' y='30' text-anchor='middle' font-family='Times New Roman, serif' font-size='22'>Twiddle Resource Comparison</text>",
        f"<line x1='{left}' y1='{bottom}' x2='830' y2='{bottom}' stroke='black' stroke-width='1.2'/>",
        f"<line x1='{left}' y1='{bottom-chart_h}' x2='{left}' y2='{bottom}' stroke='black' stroke-width='1.2'/>",
    ]

    for idx, key in enumerate(RESOURCE_KEYS):
        x0 = left + 55 + idx * group_w
        runtime_h = chart_h * float(runtime.get(key) or 0) / max_by_metric[key]
        lut_h = chart_h * float(lut.get(key) or 0) / max_by_metric[key]
        runtime_x = x0
        lut_x = x0 + bar_w + 12
        parts.extend(
            [
                f"<rect x='{runtime_x}' y='{bottom-runtime_h:.2f}' width='{bar_w}' height='{runtime_h:.2f}' fill='#111111'/>",
                f"<rect x='{lut_x}' y='{bottom-lut_h:.2f}' width='{bar_w}' height='{lut_h:.2f}' fill='#b8b8b8' stroke='#111111' stroke-width='0.8'/>",
                f"<text x='{runtime_x + bar_w/2}' y='{bottom-runtime_h-6:.2f}' text-anchor='middle' font-family='Times New Roman, serif' font-size='13'>{format_value(runtime.get(key), 0)}</text>",
                f"<text x='{lut_x + bar_w/2}' y='{bottom-lut_h-6:.2f}' text-anchor='middle' font-family='Times New Roman, serif' font-size='13'>{format_value(lut.get(key), 0)}</text>",
                f"<text x='{x0 + bar_w + 6}' y='382' text-anchor='middle' font-family='Times New Roman, serif' font-size='16'>{key.replace('_', ' ')}</text>",
            ]
        )

    parts.extend(
        [
            "<rect x='600' y='54' width='20' height='12' fill='#111111'/>",
            "<text x='628' y='65' font-family='Times New Roman, serif' font-size='15'>Runtime sin/cos</text>",
            "<rect x='600' y='78' width='20' height='12' fill='#b8b8b8' stroke='#111111' stroke-width='0.8'/>",
            "<text x='628' y='89' font-family='Times New Roman, serif' font-size='15'>Twiddle LUT</text>",
            "</svg>",
        ]
    )
    path.write_text("\n".join(parts) + "\n", encoding="utf-8")


def write_markdown(path: Path, twiddle_rows: list[dict[str, object]], bitwidth_rows: list[dict[str, object]]) -> None:
    lines = [
        "# Paper HLS Results Summary",
        "",
        "Generated from Vitis HLS reports and C-simulation logs in this folder.",
        "",
        "## Twiddle Resource Comparison",
        "",
        "| Variant | BRAM_18K | DSP | FF | LUT |",
        "|---|---:|---:|---:|---:|",
    ]

    for row in twiddle_rows:
        digits = 1 if row["Variant"] == "Reduction (%)" else 0
        lines.append(
            "| {Variant} | {BRAM_18K} | {DSP} | {FF} | {LUT} |".format(
                Variant=row["Variant"],
                BRAM_18K=format_value(row.get("BRAM_18K"), digits),
                DSP=format_value(row.get("DSP"), digits),
                FF=format_value(row.get("FF"), digits),
                LUT=format_value(row.get("LUT"), digits),
            )
        )

    lines.extend(
        [
            "",
            "## Bit-Width Sweep",
            "",
            "| Format | Pass | Worst Real MaxAbs | Worst Imag MaxAbs | BRAM_18K | DSP | FF | LUT | Status |",
            "|---|---:|---:|---:|---:|---:|---:|---:|---|",
        ]
    )

    for row in bitwidth_rows:
        lines.append(
            "| {Format} | {PassedSamples}/{TotalSamples} | {WorstRealMaxAbs} | {WorstImagMaxAbs} | {BRAM_18K} | {DSP} | {FF} | {LUT} | {Status} |".format(
                Format=row["Format"],
                PassedSamples=row["PassedSamples"],
                TotalSamples=row["TotalSamples"],
                WorstRealMaxAbs=format_value(row.get("WorstRealMaxAbs")),
                WorstImagMaxAbs=format_value(row.get("WorstImagMaxAbs")),
                BRAM_18K=format_value(row.get("BRAM_18K"), 0),
                DSP=format_value(row.get("DSP"), 0),
                FF=format_value(row.get("FF"), 0),
                LUT=format_value(row.get("LUT"), 0),
                Status=row["Status"],
            )
        )

    lines.extend(
        [
            "",
            "## Paper Note",
            "",
            "Use the Twiddle LUT row from the first table as the selected 28/20 resource row. This keeps Table V, Table VI, and Figure 6 synchronized to the same HLS report source.",
            "",
        ]
    )
    path.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--results-dir", type=Path, required=True)
    args = parser.parse_args()

    results_dir = args.results_dir.resolve()
    results_dir.mkdir(parents=True, exist_ok=True)

    twiddle_rows = collect_twiddle(results_dir)
    bitwidth_rows = collect_bitwidth(results_dir)

    write_csv(
        results_dir / "paper_twiddle_resource_summary.csv",
        twiddle_rows,
        ["Variant", "BRAM_18K", "DSP", "FF", "LUT"],
    )
    write_csv(
        results_dir / "paper_bitwidth_sweep_summary.csv",
        bitwidth_rows,
        [
            "Format",
            "TotalBits",
            "IntegerBits",
            "PassedSamples",
            "TotalSamples",
            "WorstRealMaxAbs",
            "WorstImagMaxAbs",
            "BRAM_18K",
            "DSP",
            "FF",
            "LUT",
            "Status",
        ],
    )
    write_markdown(results_dir / "paper_hls_results_summary.md", twiddle_rows, bitwidth_rows)
    write_twiddle_svg(results_dir / "paper_twiddle_resource_comparison.svg", twiddle_rows)

    print(f"Wrote paper summaries to {results_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
