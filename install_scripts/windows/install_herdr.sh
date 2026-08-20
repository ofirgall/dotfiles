#!/bin/bash
set -e
source "$(dirname "$0")/helpers.sh"

if command -v herdr &>/dev/null; then
    echo "herdr already installed"
else
    echo "Installing herdr..."
    powershell.exe -ExecutionPolicy Bypass -c "irm https://herdr.dev/install.ps1 | iex"
fi

# Add herdr to PATH for this session (installer only updates future PowerShell sessions)
export PATH="$LOCALAPPDATA/Programs/Herdr/bin:$PATH"

# Install herdr-nvim-aware plugin (nvim-aware keybindings)
if ! herdr plugin list 2>/dev/null | grep -q herdr-nvim-aware; then
    herdr plugin install KoalaVim/herdr-nvim-aware --yes
fi

# Install extrakto-herdr plugin (text extraction + fzf)
if ! herdr plugin list 2>/dev/null | grep -q extrakto-herdr; then
    herdr plugin install ofirgall/extrakto-herdr --yes
fi
