New-Item -ItemType Directory -Force -Path build | Out-Null
New-Item -ItemType Directory -Force -Path output | Out-Null

g++ -std=c++17 -O2 -Wall -Wextra -Iinclude src/main.cpp src/fft2d_reference.cpp -o build/fft2d_reference.exe

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed."
    exit 1
}

./build/fft2d_reference.exe 64 64 ../../data/input/square_64x64_matrix_2d.txt output/square_64x64 ../../data/reference/square_64x64_fft_real_2d.txt ../../data/reference/square_64x64_fft_imag_2d.txt
