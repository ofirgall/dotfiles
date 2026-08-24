#!/bin/bash
set -e

eval "$(/opt/homebrew/bin/brew shellenv)"

if command -v herdr &>/dev/null; then
    echo "herdr already installed"
else
    echo "Installing herdr..."
    brew install herdr
fi

# Install herdr-nvim-aware plugin (nvim-aware keybindings)
if ! herdr plugin list 2>/dev/null | grep -q herdr-nvim-aware; then
    herdr plugin install KoalaVim/herdr-nvim-aware --yes
fi

# Install extrakto-herdr plugin (text extraction + fzf)
if ! herdr plugin list 2>/dev/null | grep -q extrakto-herdr; then
    herdr plugin install ofirgall/extrakto-herdr --yes
fi

# Build herdr-last-tab (last-tab switcher)
echo "Building herdr-last-tab..."
cargo install --path "$HOME/dotfiles/herdr-last-tab" --force --quiet
