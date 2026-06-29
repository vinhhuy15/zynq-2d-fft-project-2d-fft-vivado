New-Item -ItemType Directory -Force -Path build | Out-Null
New-Item -ItemType Directory -Force -Path results | Out-Null

g++ -std=c++17 -O2 -Wall -Wextra -Iinclude src/fft2d_fixed.cpp tb/testbench.cpp -o build/fft2d_fixed_tb.exe

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed."
    exit 1
}

$samples = @("square", "gradient", "checker", "circle")
$dataRoot = "../../software/python_reference/zynq_2d_fft_python_reference/data"
$csvPath = "results/hls_prep_accuracy_64x64.csv"

"sample,width,height,real_mae,real_mse,real_rmse,real_max_abs,imag_mae,imag_mse,imag_rmse,imag_max_abs,status" |
    Set-Content -Path $csvPath

foreach ($sample in $samples) {
    $inputPath = "$dataRoot/input/${sample}_64x64_matrix_2d.txt"
    $refRealPath = "$dataRoot/reference/${sample}_64x64_fft_real_2d.txt"
    $refImagPath = "$dataRoot/reference/${sample}_64x64_fft_imag_2d.txt"
    $outRealPath = "${sample}_64x64_hls_prep_fft_real_2d.txt"
    $outImagPath = "${sample}_64x64_hls_prep_fft_imag_2d.txt"

    Write-Host "Running $sample 64x64..."
    $output = & ./build/fft2d_fixed_tb.exe `
        $inputPath `
        $refRealPath `
        $refImagPath `
        $outRealPath `
        $outImagPath

    $exitCode = $LASTEXITCODE
    $output | ForEach-Object { Write-Host $_ }

    $realLine = $output | Where-Object { $_ -like "Real MAE:*" }
    $imagLine = $output | Where-Object { $_ -like "Imag MAE:*" }

    if ($realLine -notmatch "Real MAE: ([0-9.eE+-]+), MSE: ([0-9.eE+-]+), RMSE: ([0-9.eE+-]+), MaxAbs: ([0-9.eE+-]+)") {
        Write-Host "Could not parse real metrics for $sample."
        exit 1
    }
    $realMae = $Matches[1]
    $realMse = $Matches[2]
    $realRmse = $Matches[3]
    $realMaxAbs = $Matches[4]

    if ($imagLine -notmatch "Imag MAE: ([0-9.eE+-]+), MSE: ([0-9.eE+-]+), RMSE: ([0-9.eE+-]+), MaxAbs: ([0-9.eE+-]+)") {
        Write-Host "Could not parse imag metrics for $sample."
        exit 1
    }
    $imagMae = $Matches[1]
    $imagMse = $Matches[2]
    $imagRmse = $Matches[3]
    $imagMaxAbs = $Matches[4]

    $status = if ($exitCode -eq 0) { "PASS" } else { "FAIL" }
    "$sample,64,64,$realMae,$realMse,$realRmse,$realMaxAbs,$imagMae,$imagMse,$imagRmse,$imagMaxAbs,$status" |
        Add-Content -Path $csvPath

    if ($exitCode -ne 0) {
        Write-Host "$sample failed."
        exit $exitCode
    }
}

Write-Host "Wrote $csvPath"
