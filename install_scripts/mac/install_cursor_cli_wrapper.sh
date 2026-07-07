#!/bin/bash
set -e

eval "$(/opt/homebrew/bin/brew shellenv)"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

if command -v cursor-cli-wrapper &>/dev/null; then
    echo "cursor-cli-wrapper already installed"
    exit 0
fi

if ! command -v cargo &>/dev/null; then
    brew install rust
    [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
fi

cargo install --git https://github.com/ofirgall/cursor-cli-wrapper
