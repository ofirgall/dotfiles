#!/bin/bash
set -e
source "$(dirname "$0")/helpers.sh"

if command -v cl.exe &>/dev/null; then
    echo "Visual C++ Build Tools already installed"
    exit 0
fi

echo "Installing Visual C++ Build Tools..."
winget.exe install --id Microsoft.VisualStudio.BuildTools \
    --accept-package-agreements --accept-source-agreements \
    --override "--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.Windows11SDK.26100" || true
echo "Visual C++ Build Tools installed"
