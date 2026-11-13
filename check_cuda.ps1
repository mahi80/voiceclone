$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$vpy = Join-Path $root ".venv\Scripts\python.exe"
if (-not (Test-Path $vpy)) { Write-Host "FAIL: run setup.ps1 first." -ForegroundColor Red; exit 1 }

& $vpy (Join-Path $root "check_cuda.py")
exit $LASTEXITCODE
