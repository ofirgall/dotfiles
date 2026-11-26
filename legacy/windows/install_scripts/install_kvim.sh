#!/bin/bash
set -e
source "$(dirname "$0")/helpers.sh"

if command -v kv &>/dev/null; then
    echo "kv already installed"
else
    CARGO_NET_GIT_FETCH_WITH_CLI=true cargo install --locked --git=https://github.com/KoalaVim/kv.git
fi

if [ ! -d "$HOME/.config/kvim-envs/main" ]; then
    kv env create main --from ~/.config/nvim
    kv install
fi
