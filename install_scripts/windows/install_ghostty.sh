#!/bin/bash
set -e
source "$(dirname "$0")/helpers.sh"

if winget.exe list --id AmanThanvi.winghostty 2>/dev/null | grep -q "winghostty"; then
    echo "winghostty already installed"
    exit 0
fi

echo "Installing winghostty (Ghostty core + native Win32 runtime)..."

winget.exe install --id AmanThanvi.winghostty --accept-package-agreements --accept-source-agreements
echo "winghostty installed"
