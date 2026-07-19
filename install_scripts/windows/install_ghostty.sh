#!/bin/bash
set -e
source "$(dirname "$0")/helpers.sh"

if [ -d "/c/Program Files/winghostty" ] || command -v winghostty &>/dev/null; then
    echo "winghostty already installed"
    exit 0
fi

echo "Installing winghostty (Ghostty core + native Win32 runtime)..."
winget.exe install --id AmanThanvi.winghostty --accept-package-agreements --accept-source-agreements || true
echo "winghostty installed"
