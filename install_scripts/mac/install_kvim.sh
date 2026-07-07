#!/bin/bash
set -e

eval "$(/opt/homebrew/bin/brew shellenv)"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

if ! command -v cargo &>/dev/null; then
    brew install rust
    [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
fi

if command -v kv &>/dev/null; then
    echo "kv already installed"
else
    CARGO_NET_GIT_FETCH_WITH_CLI=true cargo install --locked --git=https://github.com/KoalaVim/kv.git
fi

if [ ! -d "$HOME/.config/kvim-envs/main" ]; then
    kv env create main --from ~/.config/nvim
fi
