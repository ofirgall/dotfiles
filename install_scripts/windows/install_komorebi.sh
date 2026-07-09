#!/bin/bash
set -e
source "$(dirname "$0")/helpers.sh"

if winget.exe list --id LGUG2Z.komorebi 2>/dev/null | grep -q "komorebi"; then
    echo "Komorebi already installed"
else
    echo "Installing Komorebi..."
    winget.exe install --id LGUG2Z.komorebi --accept-package-agreements --accept-source-agreements
fi

if winget.exe list --id LGUG2Z.whkd 2>/dev/null | grep -q "whkd"; then
    echo "whkd already installed"
else
    echo "Installing whkd..."
    winget.exe install --id LGUG2Z.whkd --accept-package-agreements --accept-source-agreements
fi

# Enable autostart with whkd
komorebic.exe enable-autostart --whkd 2>/dev/null || true
echo "Komorebi autostart enabled"
