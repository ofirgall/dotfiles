# Windows dotfiles bootstrap — runs dotbot with system Python and Git Bash.
# Run from PowerShell: .\install-windows.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# 1. Check symlink capability (requires Developer Mode or admin)
$testTarget = [System.IO.Path]::GetTempFileName()
$testLink = "$testTarget.link"
$mklinkOut = cmd /c "mklink `"$testLink`" `"$testTarget`"" 2>&1
if (Test-Path $testLink) {
    Remove-Item $testLink -Force
    Remove-Item $testTarget -Force
} else {
    Remove-Item $testTarget -Force -ErrorAction SilentlyContinue
    Write-Error "Cannot create symlinks. Enable Developer Mode (Settings > System > For Developers) or run as Administrator, then re-run this script."
    exit 1
}

# 2. Ensure Git is installed (provides bash.exe for install scripts)
$gitBash = "C:\Program Files\Git\bin\bash.exe"
if (-not (Test-Path $gitBash)) {
    Write-Host "Installing Git for Windows..."
    winget install --id Git.Git --accept-package-agreements --accept-source-agreements
    if (-not (Test-Path $gitBash)) {
        Write-Error "Git installation failed — $gitBash not found."
        exit 1
    }
} else {
    Write-Host "Git for Windows already installed"
}

# 3. Ensure Python is installed (needed for dotbot)
if (-not (Get-Command python -ErrorAction SilentlyContinue) -or
    (python --version 2>&1) -match "was not found") {
    Write-Host "Installing Python..."
    winget install --id Python.Python.3.12 --accept-package-agreements --accept-source-agreements
} else {
    Write-Host "Python already installed: $(python --version)"
}

# 4. Init submodules
Write-Host "Initializing submodules..."
git submodule update --init --recursive

# 5. Run dotbot with system Python
$repoDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$dotbotBin = Join-Path $repoDir "dotbot\bin\dotbot"
$configFile = Join-Path $repoDir "windows.conf.yaml"

Write-Host "Running dotbot..."
python $dotbotBin -d $repoDir -c $configFile @args
