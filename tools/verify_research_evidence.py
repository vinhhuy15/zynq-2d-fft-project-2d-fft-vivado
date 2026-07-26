#!/usr/bin/env python3
"""Check that curated HLS summaries still match their source XML reports."""

from __future__ import annotations

import csv
import sys
import xml.etree.ElementTree as ET
from pathlib import Path


RESOURCE_KEYS = ("BRAM_18K", "DSP", "FF", "LUT")


def parse_resources(path: Path) -> dict[str, int]:
    root = ET.parse(path).getroot()
    for node in root.iter():
        values = {child.tag: child.text for child in node}
        if all(key in values for key in RESOURCE_KEYS):
            return {key: int(float(values[key])) for key in RESOURCE_KEYS}
    raise ValueError(f"No HLS resource summary found in {path}")


def read_rows(path: Path, key: str) -> dict[str, dict[str, str]]:
    with path.open(newline="", encoding="utf-8") as stream:
        return {row[key]: row for row in csv.DictReader(stream)}


def row_resources(row: dict[str, str]) -> dict[str, int]:
    return {key: int(float(row[key])) for key in RESOURCE_KEYS}


def require_equal(label: str, actual: object, expected: object) -> None:
    if actual != expected:
        raise AssertionError(f"{label}: expected {expected!r}, got {actual!r}")


def main() -> int:
    repo = Path(__file__).resolve().parents[1]
    evidence = repo / "hls" / "fft2d_accel" / "results" / "paper_reproduce_64"

    twiddle_rows = read_rows(evidence / "paper_twiddle_resource_summary.csv", "Variant")
    bitwidth_rows = read_rows(evidence / "paper_bitwidth_sweep_summary.csv", "Format")

    report_pairs = (
        ("Runtime sin/cos", "runtime_trig_28_20_csynth.xml"),
        ("Twiddle LUT", "twiddle_lut_28_20_csynth.xml"),
    )
    for variant, report_name in report_pairs:
        require_equal(
            f"{variant} resource summary",
            row_resources(twiddle_rows[variant]),
            parse_resources(evidence / report_name),
        )

    for fmt, report_name in (
        ("ap_fixed<28,20>", "bitwidth_28_20_csynth.xml"),
        ("ap_fixed<32,20>", "bitwidth_32_20_csynth.xml"),
    ):
        require_equal(
            f"{fmt} resource summary",
            row_resources(bitwidth_rows[fmt]),
            parse_resources(evidence / report_name),
        )

    selected = bitwidth_rows["ap_fixed<28,20>"]
    require_equal("selected format status", selected["Status"], "PASS")
    require_equal("selected format sample count", selected["PassedSamples"], selected["TotalSamples"])

    failed_formats = {
        row["Format"]
        for row in bitwidth_rows.values()
        if row["Status"] == "FAIL"
    }
    require_equal(
        "failed fixed-point candidates",
        failed_formats,
        {
            "ap_fixed<24,20>",
            "ap_fixed<22,20>",
            "ap_fixed<24,16>",
            "ap_fixed<24,12>",
            "ap_fixed<20,12>",
        },
    )

    print("Research evidence is internally consistent.")
    print(f"Checked {len(report_pairs) + 2} source reports and {len(bitwidth_rows)} bit-width rows.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (AssertionError, KeyError, OSError, ValueError, ET.ParseError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        raise SystemExit(1)
