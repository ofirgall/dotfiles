#!/bin/bash
set -e
source "$(dirname "$0")/helpers.sh"

if [ -x "/c/Program Files/noctty/noctty.exe" ] || [ -x "/c/Program Files/winghostty/noctty.exe" ] || command -v noctty &>/dev/null; then
    echo "noctty already installed"
    exit 0
fi

echo "Installing noctty (formerly winghostty)..."
winget.exe install --id AmanThanvi.noctty -e --accept-package-agreements --accept-source-agreements || true
echo "noctty installed"
