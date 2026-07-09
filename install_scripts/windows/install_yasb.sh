#!/bin/bash
set -e
source "$(dirname "$0")/helpers.sh"

if winget.exe list --id AmN.yasb 2>/dev/null | grep -q "yasb"; then
    echo "Yasb already installed"
    exit 0
fi

echo "Installing Yasb..."
winget.exe install --id AmN.yasb --accept-package-agreements --accept-source-agreements
