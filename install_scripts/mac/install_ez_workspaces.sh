#!/bin/bash
set -e

eval "$(/opt/homebrew/bin/brew shellenv)"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

if command -v ez &>/dev/null; then
    echo "ez-workspaces already installed"
    exit 0
fi

if ! command -v cargo &>/dev/null; then
    brew install rust
    [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
fi

cargo install --git https://github.com/KoalaVim/ez-workspaces
