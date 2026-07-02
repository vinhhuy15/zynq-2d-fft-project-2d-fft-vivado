param(
    [string]$VitisRun = "C:\AMDDesignTools\2025.2\Vitis\bin\vitis-run.bat",
    [switch]$SkipHls
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

$ResultsDir = Join-Path $ScriptDir "results\paper_reproduce_64"
New-Item -ItemType Directory -Force -Path $ResultsDir | Out-Null

if (-not $SkipHls) {
    if (-not (Test-Path $VitisRun)) {
        throw "Cannot find Vitis runner: $VitisRun. Pass -VitisRun with your local vitis-run.bat path."
    }

    & $VitisRun --mode hls --tcl run_hls_paper_tables_64.tcl
}

$Python = Get-Command python -ErrorAction SilentlyContinue
if ($null -eq $Python) {
    $Python = Get-Command py -ErrorAction SilentlyContinue
}
if ($null -eq $Python) {
    throw "Cannot find python or py on PATH. Install Python or run the collector manually with a Python executable."
}

& $Python.Source .\tools\collect_paper_hls_results.py --results-dir $ResultsDir

Write-Host ""
Write-Host "Paper reproduction outputs:"
Write-Host "  $ResultsDir\paper_hls_results_summary.md"
Write-Host "  $ResultsDir\paper_twiddle_resource_summary.csv"
Write-Host "  $ResultsDir\paper_bitwidth_sweep_summary.csv"
Write-Host "  $ResultsDir\paper_twiddle_resource_comparison.svg"
