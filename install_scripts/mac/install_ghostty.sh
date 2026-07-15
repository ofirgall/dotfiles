#!/bin/bash
set -e

eval "$(/opt/homebrew/bin/brew shellenv)"

if brew list --cask ghostty &>/dev/null; then
    echo "Ghostty already installed"
    exit 0
fi

brew install --cask ghostty
