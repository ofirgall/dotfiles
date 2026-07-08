#!/bin/bash
set -e

eval "$(/opt/homebrew/bin/brew shellenv)"

if brew list --cask linearmouse &>/dev/null; then
    echo "LinearMouse already installed"
    exit 0
fi

brew install --cask linearmouse
/usr/bin/open -a "Linear Mouse"
echo "LinearMouse launched — grant Accessibility permissions when prompted"
