#!/bin/bash
set -e

if ! command -v brew &>/dev/null; then
    echo "Homebrew not found, skipping BetterDisplay installation"
    exit 1
fi

if brew list --cask betterdisplay &>/dev/null; then
    echo "BetterDisplay already installed"
else
    echo "Installing BetterDisplay..."
    brew install --cask betterdisplay
fi
