#!/bin/bash
set -e

eval "$(/opt/homebrew/bin/brew shellenv)"

if brew list --cask betterdisplay &>/dev/null; then
    echo "BetterDisplay already installed"
else
    echo "Installing BetterDisplay..."
    brew install --cask betterdisplay
fi
