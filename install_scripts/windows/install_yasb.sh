#!/bin/bash
set -e
source "$(dirname "$0")/helpers.sh"

if [ -d "/c/Program Files/YASB" ] || command -v yasb &>/dev/null; then
    echo "Yasb already installed"
    exit 0
fi

echo "Installing Yasb..."
winget.exe install --id AmN.yasb --accept-package-agreements --accept-source-agreements
