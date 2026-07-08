#!/bin/bash
set -e

eval "$(/opt/homebrew/bin/brew shellenv)"

if [ -d "/Applications/AeroSpace.app" ]; then
    echo "AeroSpace already installed"
    exit 0
fi

brew install --cask nikitabobko/tap/aerospace
