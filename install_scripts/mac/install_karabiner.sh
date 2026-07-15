#!/bin/bash
set -e

eval "$(/opt/homebrew/bin/brew shellenv)"

if brew list --cask karabiner-elements &>/dev/null; then
    echo "Karabiner-Elements already installed"
    exit 0
fi

brew install --cask karabiner-elements
/usr/bin/open -a "Karabiner-Elements"
echo "Karabiner launched — grant Input Monitoring permissions when prompted"
