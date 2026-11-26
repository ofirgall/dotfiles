#!/bin/bash
set -e
source "$(dirname "$0")/helpers.sh"

if command -v wezterm &>/dev/null; then
    echo "WezTerm already installed"
    exit 0
fi

echo "Installing WezTerm..."
winget.exe install --id wez.wezterm --accept-package-agreements --accept-source-agreements
echo "WezTerm installed"
