#!/bin/bash
set -e

eval "$(/opt/homebrew/bin/brew shellenv)"

if command -v ez &>/dev/null; then
    echo "ez-workspaces already installed"
    exit 0
fi

if ! command -v cargo &>/dev/null; then
    brew install rust
fi

cargo install --git https://github.com/KoalaVim/ez-workspaces
