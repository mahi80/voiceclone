$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

function Fail($msg) {
    Write-Host "FAIL: $msg" -ForegroundColor Red
    exit 1
}

# --- Prerequisites ---------------------------------------------------------
$py = Get-Command py -ErrorAction SilentlyContinue
if (-not $py) { Fail "Python launcher (py.exe) not found. Install Python 3.10 and tick 'Add to PATH'." }

& py -3.10 --version 2>$null
if ($LASTEXITCODE -ne 0) { Fail "Python 3.10 missing. Run: winget install --id Python.Python.3.10 -e" }

$git = Get-Command git -ErrorAction SilentlyContinue
if (-not $git) { Fail "git not found. Install from https://git-scm.com/download/win" }

if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Host "WARN: ffmpeg not on PATH (only needed by prep_reference.py)." -ForegroundColor Yellow
}

# --- Seed-VC source --------------------------------------------------------
if (-not (Test-Path "seed-vc\real-time-gui.py")) {
    Write-Host "Cloning seed-vc..." -ForegroundColor Cyan
    & git clone --depth 1 https://github.com/Plachtaa/seed-vc.git seed-vc
    if ($LASTEXITCODE -ne 0) { Fail "git clone failed." }
}

# --- Virtualenv ------------------------------------------------------------
if (-not (Test-Path ".venv\Scripts\python.exe")) {
    Write-Host "Creating Python 3.10 venv..." -ForegroundColor Cyan
    & py -3.10 -m venv .venv
    if ($LASTEXITCODE -ne 0) { Fail "venv creation failed." }
}
$vpy = Join-Path $root ".venv\Scripts\python.exe"

& $vpy -m pip install --upgrade pip wheel
if ($LASTEXITCODE -ne 0) { Fail "pip upgrade failed." }

# --- Torch (CUDA 12.4 build of the pinned 2.4.0) ---------------------------
Write-Host "Installing torch 2.4.0 + cu124 (~2.5 GB)..." -ForegroundColor Cyan
& $vpy -m pip install torch==2.4.0 torchvision==0.19.0 torchaudio==2.4.0 `
    --index-url https://download.pytorch.org/whl/cu124
if ($LASTEXITCODE -ne 0) { Fail "torch install failed (check internet / NVIDIA driver)." }

# --- Remaining seed-vc deps (torch lines filtered; already installed above) --
$filtered = Join-Path $root "requirements-filtered.txt"
Get-Content "seed-vc\requirements.txt" |
    Where-Object { $_ -match '\S' -and $_ -notmatch '^(torch|torchvision|torchaudio)\b' } |
    Set-Content $filtered

Write-Host "Installing seed-vc dependencies..." -ForegroundColor Cyan
& $vpy -m pip install -r $filtered
if ($LASTEXITCODE -ne 0) { Fail "dependency install failed (see output above)." }

Write-Host ""
Write-Host "Installed. Next:" -ForegroundColor Green
Write-Host "  1) powershell -ExecutionPolicy Bypass -File .\check_cuda.ps1"
Write-Host "  2) .\.venv\Scripts\python.exe .\prep_reference.py <recording> ref_you.wav"
Write-Host "  3) powershell -ExecutionPolicy Bypass -File .\run_realtime.ps1"
