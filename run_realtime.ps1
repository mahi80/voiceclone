$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$vpy = Join-Path $root ".venv\Scripts\python.exe"

if (-not (Test-Path $vpy)) { Write-Host "FAIL: run setup.ps1 first." -ForegroundColor Red; exit 1 }
if (-not (Test-Path (Join-Path $root "seed-vc\real-time-gui.py"))) {
    Write-Host "FAIL: seed-vc missing. Re-run setup.ps1." -ForegroundColor Red; exit 1
}

# real-time-gui.py imports its modules relative to the working directory
Push-Location (Join-Path $root "seed-vc")
try {
    & $vpy "real-time-gui.py" @args
} finally {
    Pop-Location
}
