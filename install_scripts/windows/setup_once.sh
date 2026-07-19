#!/bin/bash
set -e

echo "Applying one-time Windows settings..."

# Key repeat rate (fastest)
# MSYS_NO_PATHCONV prevents MSYS2 from converting registry paths
MSYS_NO_PATHCONV=1 reg add "HKCU\Control Panel\Keyboard" /v KeyboardDelay /t REG_SZ /d 0 /f
MSYS_NO_PATHCONV=1 reg add "HKCU\Control Panel\Keyboard" /v KeyboardSpeed /t REG_SZ /d 31 /f

# Disable snap assist popup (komorebi handles tiling)
MSYS_NO_PATHCONV=1 reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v SnapAssist /t REG_DWORD /d 0 /f

# Set KOMOREBI_CONFIG_HOME so komorebi reads from ~/.config/komorebi
powershell.exe -NoProfile -Command '[Environment]::SetEnvironmentVariable("KOMOREBI_CONFIG_HOME", "$env:USERPROFILE\.config\komorebi", "User")'

# Add komorebi and whkd to user PATH
powershell.exe -NoProfile -Command '
$path = [Environment]::GetEnvironmentVariable("Path", "User")
$additions = @("C:\Program Files\komorebi\bin", "C:\Program Files\whkd\bin")
foreach ($dir in $additions) {
    if ($path -notlike "*$dir*") { $path += ";$dir" }
}
[Environment]::SetEnvironmentVariable("Path", $path, "User")
'

# Install BurntToast PowerShell module for rich Windows notifications
powershell.exe -NoProfile -Command '
if (-not (Get-Module -ListAvailable -Name BurntToast -ErrorAction SilentlyContinue)) {
    Install-Module BurntToast -Scope CurrentUser -Force
    Write-Host "BurntToast module installed"
} else {
    Write-Host "BurntToast module already installed"
}
'

echo "Some changes require logout to take effect"
