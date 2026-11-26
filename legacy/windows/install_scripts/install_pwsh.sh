#!/bin/bash
set -e
source "$(dirname "$0")/helpers.sh"

if command -v pwsh.exe &>/dev/null; then
    echo "PowerShell 7 already installed"
    exit 0
fi

echo "Installing PowerShell 7..."
winget.exe install --id Microsoft.PowerShell --accept-package-agreements --accept-source-agreements || true
echo "PowerShell 7 installed"
