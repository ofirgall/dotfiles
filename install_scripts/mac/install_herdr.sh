#!/bin/bash
set -e

eval "$(/opt/homebrew/bin/brew shellenv)"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

if ! command -v cargo &>/dev/null; then
    brew install rust
    [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
fi

HERDR_DIR="$HOME/workspace/personal/herdr"

if [ ! -d "$HERDR_DIR" ]; then
    echo "ERROR: herdr clone not found at $HERDR_DIR"
    exit 1
fi

if [ -z "$ZIG" ] && [ -x "/opt/homebrew/opt/zig@0.15/bin/zig" ]; then
    export ZIG="/opt/homebrew/opt/zig@0.15/bin/zig"
fi

if ! brew list zig@0.15 &>/dev/null; then
    brew install zig@0.15
fi

echo "Building herdr from $HERDR_DIR..."
cargo install --path "$HERDR_DIR" --locked
