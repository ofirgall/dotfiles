#!/bin/bash
set -e
source "$(dirname "$0")/helpers.sh"

# Ensure gcc temp dirs are set (Python subprocess may not inherit Windows TEMP)
_tmpdir="${TMPDIR:-${TEMP:-${TMP:-$HOME/AppData/Local/Temp}}}"
export TMPDIR="$_tmpdir" TMP="$_tmpdir" TEMP="$_tmpdir"

# Cargo packages (cross-platform)
cargo install difftastic
cargo install du-dust
cargo install git-delta
cargo install igrep
cargo install bottom --locked
cargo install tuitab
cargo install lemmy-help --features=cli

# jless uses termion (Unix-only) — skip on Windows

# yj (YAML/JSON converter)
if ! command -v yj &>/dev/null; then
    cargo install yj
fi

# Python packages
python3 -m pip install --break-system-packages libtmux
# brotab depends on psutil which doesn't support MSYS2 — skip on Windows

# Ghostty shaders
if [ ! -d "$HOME/.config/ghostty/shaders" ]; then
    mkdir -p "$HOME/.config/ghostty"
    git clone https://github.com/sahaj-b/ghostty-cursor-shaders ~/.config/ghostty/shaders
fi
