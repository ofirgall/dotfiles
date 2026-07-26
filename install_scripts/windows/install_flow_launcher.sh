#!/bin/bash
set -e
source "$(dirname "$0")/helpers.sh"

if command -v flow-launcher &>/dev/null || [ -d "$LOCALAPPDATA/FlowLauncher" ]; then
    echo "Flow Launcher already installed"
else
    echo "Installing Flow Launcher..."
    winget.exe install --id Flow-Launcher.Flow-Launcher --accept-package-agreements --accept-source-agreements
fi

echo "NOTE: Install plugins manually (see winREADME/MANUAL.md)"
