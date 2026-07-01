param(
    [string]$PortName = "COM4",
    [int]$BaudRate = 115200,
    [string]$OutFile = "data/fpga_uart_logs/demo_uart.log",
    [int]$IdleTimeoutSeconds = 20
)

$ErrorActionPreference = "Stop"

$outPath = Resolve-Path -Path "." | ForEach-Object { Join-Path $_.Path $OutFile }
$outDir = Split-Path -Parent $outPath
New-Item -ItemType Directory -Path $outDir -Force | Out-Null

$serial = New-Object System.IO.Ports.SerialPort $PortName, $BaudRate, "None", 8, "One"
$serial.ReadTimeout = 1000

try {
    $serial.Open()
    "Capturing $PortName at $BaudRate baud to $outPath"
    "Close any other serial monitor before running this script."
    Set-Content -Path $outPath -Value "" -Encoding UTF8

    $lastLineTime = Get-Date
    while ($true) {
        try {
            $line = $serial.ReadLine()
            $lastLineTime = Get-Date
            $line = $line.TrimEnd("`r", "`n")
            Write-Host $line
            Add-Content -Path $outPath -Value $line -Encoding UTF8

            if ($line -match "RGB FFT hardware test passed|RGB FFT hardware test failed") {
                break
            }
        } catch [System.TimeoutException] {
            $idle = (Get-Date) - $lastLineTime
            if ($idle.TotalSeconds -ge $IdleTimeoutSeconds) {
                "Idle timeout reached after $IdleTimeoutSeconds seconds."
                break
            }
        }
    }
} finally {
    if ($serial.IsOpen) {
        $serial.Close()
    }
}

"Saved UART log: $outPath"
