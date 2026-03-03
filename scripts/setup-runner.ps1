# setup-runner.ps1 - Downloads and configures GitHub Actions self-hosted runner
# Run this script as Administrator

$ErrorActionPreference = "Stop"

Write-Host "=== GitHub Actions Self-Hosted Runner Setup ===" -ForegroundColor Cyan
Write-Host ""

# Configuration
$RunnerDir = "C:\actions-runner"
$RepoUrl = "https://github.com/TECHNICANGEL/emergent"

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Please run this script as Administrator" -ForegroundColor Red
    exit 1
}

# Create runner directory
if (-not (Test-Path $RunnerDir)) {
    New-Item -ItemType Directory -Path $RunnerDir -Force | Out-Null
    Write-Host "Created runner directory: $RunnerDir" -ForegroundColor Green
}

Set-Location $RunnerDir

# Download latest runner
Write-Host "Downloading GitHub Actions runner..." -ForegroundColor Yellow
$releases = Invoke-RestMethod -Uri "https://api.github.com/repos/actions/runner/releases/latest"
$asset = $releases.assets | Where-Object { $_.name -like "*win-x64*" -and $_.name -like "*.zip" } | Select-Object -First 1
$downloadUrl = $asset.browser_download_url
$zipFile = Join-Path $RunnerDir "actions-runner.zip"

if (-not (Test-Path (Join-Path $RunnerDir "config.cmd"))) {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile
    Write-Host "Extracting runner..." -ForegroundColor Yellow
    Expand-Archive -Path $zipFile -DestinationPath $RunnerDir -Force
    Remove-Item $zipFile
    Write-Host "Runner extracted" -ForegroundColor Green
} else {
    Write-Host "Runner already downloaded" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== MANUAL STEPS REQUIRED ===" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Go to: $RepoUrl/settings/actions/runners/new" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Copy the token shown on that page" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Run the following command in this directory ($RunnerDir):" -ForegroundColor Cyan
Write-Host ""
Write-Host "   .\config.cmd --url $RepoUrl --token YOUR_TOKEN_HERE" -ForegroundColor White
Write-Host ""
Write-Host "4. After configuration, install as a Windows service:" -ForegroundColor Cyan
Write-Host ""
Write-Host "   .\svc.cmd install" -ForegroundColor White
Write-Host "   .\svc.cmd start" -ForegroundColor White
Write-Host ""
Write-Host "=== Runner Directory: $RunnerDir ===" -ForegroundColor Green
