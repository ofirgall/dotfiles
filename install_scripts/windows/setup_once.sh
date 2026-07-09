#!/bin/bash
set -e

echo "Applying one-time Windows settings..."

# Key repeat rate (fastest)
# MSYS_NO_PATHCONV prevents MSYS2 from converting registry paths
MSYS_NO_PATHCONV=1 reg add "HKCU\Control Panel\Keyboard" /v KeyboardDelay /t REG_SZ /d 0 /f
MSYS_NO_PATHCONV=1 reg add "HKCU\Control Panel\Keyboard" /v KeyboardSpeed /t REG_SZ /d 31 /f

# Disable snap assist popup (komorebi handles tiling)
MSYS_NO_PATHCONV=1 reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v SnapAssist /t REG_DWORD /d 0 /f

echo "Some changes require logout to take effect"
