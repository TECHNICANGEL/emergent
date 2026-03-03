# deploy.ps1 - Deployment script for emergent
# This script is called by GitHub Actions on the self-hosted runner

$ErrorActionPreference = "Stop"

Write-Host "=== Emergent Deployment Script ===" -ForegroundColor Cyan

# Configuration
$ServiceName = "emergent"
$ProjectRoot = $PSScriptRoot | Split-Path -Parent
$PythonExe = Join-Path $ProjectRoot "venv\Scripts\python.exe"
$LogDir = Join-Path $ProjectRoot "logs"
$DataDir = Join-Path $ProjectRoot "data"

# Ensure directories exist
$dirs = @($LogDir, $DataDir, "$LogDir\thought-stream", "$LogDir\interactions", "$LogDir\memory-snapshots")
foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "Created directory: $dir" -ForegroundColor Green
    }
}

# Check if emergent process is running and stop it
$existingProcess = Get-Process -Name "python" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -like "*loop.py*" }

if ($existingProcess) {
    Write-Host "Stopping existing emergent process (PID: $($existingProcess.Id))..." -ForegroundColor Yellow
    Stop-Process -Id $existingProcess.Id -Force
    Start-Sleep -Seconds 2
    Write-Host "Process stopped" -ForegroundColor Green
}

# Validate Python environment
if (-not (Test-Path $PythonExe)) {
    Write-Host "Python venv not found at $PythonExe" -ForegroundColor Red
    exit 1
}

# Validate model file exists (check .env)
$envFile = Join-Path $ProjectRoot ".env"
if (Test-Path $envFile) {
    $envContent = Get-Content $envFile
    $modelPath = ($envContent | Where-Object { $_ -match "^MODEL_PATH=" }) -replace "MODEL_PATH=", ""

    if ($modelPath -and -not (Test-Path $modelPath)) {
        Write-Host "Warning: Model file not found at $modelPath" -ForegroundColor Yellow
        Write-Host "The system will not start until a model is configured." -ForegroundColor Yellow
    }
}

# Optional: Start the consciousness loop (uncomment when ready)
# $loopScript = Join-Path $ProjectRoot "src\core\loop.py"
# if (Test-Path $loopScript) {
#     Write-Host "Starting consciousness loop..." -ForegroundColor Cyan
#     Start-Process -FilePath $PythonExe -ArgumentList $loopScript -WindowStyle Hidden
#     Write-Host "Consciousness loop started" -ForegroundColor Green
# }

Write-Host ""
Write-Host "=== Deployment Complete ===" -ForegroundColor Cyan
Write-Host "Project root: $ProjectRoot"
Write-Host "Log directory: $LogDir"
Write-Host "Data directory: $DataDir"
