#!/bin/bash
set -e
source "$(dirname "$0")/helpers.sh"

if command -v winghostty &>/dev/null || command -v ghostty &>/dev/null; then
    echo "Ghostty already installed"
    exit 0
fi

echo "Installing winghostty (Ghostty core + native Win32 runtime)..."

winget.exe install --id AmanThanvi.winghostty --accept-package-agreements --accept-source-agreements
echo "winghostty installed"
