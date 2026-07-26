New-Item -ItemType Directory -Force -Path build | Out-Null
New-Item -ItemType Directory -Force -Path results/portable | Out-Null
New-Item -ItemType Directory -Force -Path build/portable-output | Out-Null

g++ -std=c++17 -O2 -Wall -Wextra -Iinclude src/fft2d_fixed.cpp tb/testbench.cpp -o build/fft2d_fixed_tb.exe

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed."
    exit 1
}

$samples = @("square", "gradient", "checker", "circle")
$dataRoot = "../../software/python_reference/zynq_2d_fft_python_reference/data"
$channels = @("r", "g", "b")
$csvPath = "results/portable/hls_prep_color_accuracy_64x64.csv"
$outputDir = "build/portable-output"

"sample,channel,width,height,real_mae,real_mse,real_rmse,real_max_abs,imag_mae,imag_mse,imag_rmse,imag_max_abs,status" |
    Set-Content -Path $csvPath

foreach ($sample in $samples) {
    $inputPaths = $channels | ForEach-Object { "$dataRoot/input/${sample}_64x64_${_}_matrix_2d.txt" }
    $refRealPaths = $channels | ForEach-Object { "$dataRoot/reference/${sample}_64x64_${_}_fft_real_2d.txt" }
    $refImagPaths = $channels | ForEach-Object { "$dataRoot/reference/${sample}_64x64_${_}_fft_imag_2d.txt" }
    $outRealPaths = $channels | ForEach-Object { "$outputDir/${sample}_64x64_${_}_hls_prep_fft_real_2d.txt" }
    $outImagPaths = $channels | ForEach-Object { "$outputDir/${sample}_64x64_${_}_hls_prep_fft_imag_2d.txt" }

    Write-Host "Running $sample 64x64..."
    $output = & ./build/fft2d_fixed_tb.exe `
        $inputPaths[0] `
        $inputPaths[1] `
        $inputPaths[2] `
        $refRealPaths[0] `
        $refRealPaths[1] `
        $refRealPaths[2] `
        $refImagPaths[0] `
        $refImagPaths[1] `
        $refImagPaths[2] `
        $outRealPaths[0] `
        $outRealPaths[1] `
        $outRealPaths[2] `
        $outImagPaths[0] `
        $outImagPaths[1] `
        $outImagPaths[2]

    $exitCode = $LASTEXITCODE
    $output | ForEach-Object { Write-Host $_ }

    $status = if ($exitCode -eq 0) { "PASS" } else { "FAIL" }

    foreach ($channel in $channels) {
        $realLine = $output | Where-Object { $_ -like "Channel $channel Real MAE:*" }
        $imagLine = $output | Where-Object { $_ -like "Channel $channel Imag MAE:*" }

        if ($realLine -notmatch "Channel $channel Real MAE: ([0-9.eE+-]+), MSE: ([0-9.eE+-]+), RMSE: ([0-9.eE+-]+), MaxAbs: ([0-9.eE+-]+)") {
            Write-Host "Could not parse real metrics for $sample channel $channel."
            exit 1
        }
        $realMae = $Matches[1]
        $realMse = $Matches[2]
        $realRmse = $Matches[3]
        $realMaxAbs = $Matches[4]

        if ($imagLine -notmatch "Channel $channel Imag MAE: ([0-9.eE+-]+), MSE: ([0-9.eE+-]+), RMSE: ([0-9.eE+-]+), MaxAbs: ([0-9.eE+-]+)") {
            Write-Host "Could not parse imag metrics for $sample channel $channel."
            exit 1
        }
        $imagMae = $Matches[1]
        $imagMse = $Matches[2]
        $imagRmse = $Matches[3]
        $imagMaxAbs = $Matches[4]

        "$sample,$channel,64,64,$realMae,$realMse,$realRmse,$realMaxAbs,$imagMae,$imagMse,$imagRmse,$imagMaxAbs,$status" |
            Add-Content -Path $csvPath
    }

    if ($exitCode -ne 0) {
        Write-Host "$sample failed."
        exit $exitCode
    }
}

Write-Host "Wrote $csvPath"
