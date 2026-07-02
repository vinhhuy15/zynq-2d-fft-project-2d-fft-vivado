# Paper HLS Reproduction Flow

This folder contains a single reproduction flow for the paper's HLS resource and accuracy numbers. It is intended to keep Table V, Table VI, and the Figure 6 replacement synchronized to the same Vitis HLS reports.

## Run

From PowerShell:

```powershell
cd D:\zynq-2d-fft-project-2d-fft-vivado\hls\fft2d_accel
.\run_paper_reproduce_windows.ps1
```

If Vitis is installed in a different location:

```powershell
.\run_paper_reproduce_windows.ps1 -VitisRun "C:\path\to\Vitis\bin\vitis-run.bat"
```

To regenerate the CSV, Markdown, and SVG files from existing reports without rerunning HLS:

```powershell
.\run_paper_reproduce_windows.ps1 -SkipHls
```

## Outputs

All generated files are written to:

```text
results\paper_reproduce_64
```

Important files:

- `paper_hls_results_summary.md`: human-readable values for paper editing.
- `paper_twiddle_resource_summary.csv`: resource comparison for Table V.
- `paper_bitwidth_sweep_summary.csv`: accuracy and resource summary for Table VI.
- `paper_twiddle_resource_comparison.svg`: neutral grayscale Figure 6 replacement.
- `runtime_trig_28_20_csynth.rpt` and `twiddle_lut_28_20_csynth.rpt`: original HLS reports for screenshot/audit.

The selected 28/20 Twiddle LUT resource row is copied into the bit-width results, so Table V, Table VI, and Figure 6 can be updated from the same HLS report source.
