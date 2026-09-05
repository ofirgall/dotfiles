#!/bin/bash
set -e

eval "$(/opt/homebrew/bin/brew shellenv)"

if command -v herdr &>/dev/null; then
    echo "herdr already installed"
else
    echo "Installing herdr from ofirgall fork..."
    cargo install --git https://github.com/ofirgall/herdr
fi

# Install herdr-nvim-aware plugin (nvim-aware keybindings)
if ! herdr plugin list 2>/dev/null | grep -q herdr-nvim-aware; then
    herdr plugin install KoalaVim/herdr-nvim-aware --yes
fi

# Install extrakto-herdr plugin (text extraction + fzf)
if ! herdr plugin list 2>/dev/null | grep -q extrakto-herdr; then
    herdr plugin install ofirgall/extrakto-herdr --yes
fi

# Install herdr-automatic-rename plugin (auto-name tabs/workspaces)
if ! herdr plugin list 2>/dev/null | grep -q herdr-automatic-rename; then
    herdr plugin install ofirgall/herdr-automatic-rename --yes
fi

# Install herdr-navigator plugin (fuzzy jump to workspace/agent/project)
if ! herdr plugin list 2>/dev/null | grep -q herdr-navigator; then
    herdr plugin install ofirgall/herdr-navigator --yes
fi

# Install herdr-reviewr plugin (review agent diffs)
if ! herdr plugin list 2>/dev/null | grep -q persiyanov.reviewr; then
    herdr plugin install ofirgall/herdr-reviewr --yes
fi

# Install herdr-pr-tracker plugin (track PRs from Claude Code sessions)
if ! herdr plugin list 2>/dev/null | grep -q herdr-pr-tracker; then
    herdr plugin install ofirgall/herdr-pr-tracker --yes
fi

# Install herdr terminfo (undercurl support)
tic -o ~/.terminfo -x "$HOME/dotfiles/dotfiles/herdr/herdr-256color.terminfo"

# Build herdr-last-tab (last-tab switcher)
echo "Building herdr-last-tab..."
cargo install --path "$HOME/dotfiles/herdr-last-tab" --force --quiet
