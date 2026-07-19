#!/bin/bash
set -e
source "$(dirname "$0")/helpers.sh"

winget_installed() {
    winget.exe list --id "$1" 2>/dev/null | grep -q "$2"
}

if winget_installed LGUG2Z.komorebi komorebi; then
    echo "Komorebi already installed"
else
    echo "Installing Komorebi..."
    winget.exe install --id LGUG2Z.komorebi --accept-package-agreements --accept-source-agreements
fi

if winget_installed LGUG2Z.whkd whkd; then
    echo "whkd already installed"
else
    echo "Installing whkd..."
    winget.exe install --id LGUG2Z.whkd --accept-package-agreements --accept-source-agreements
fi

# Enable autostart with whkd
komorebic.exe enable-autostart --whkd 2>/dev/null || true
echo "Komorebi autostart enabled"
