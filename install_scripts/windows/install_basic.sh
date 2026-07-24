#!/bin/bash
set -e
source "$(dirname "$0")/helpers.sh"

# Ensure gcc temp dirs are set (Python subprocess may not inherit Windows TEMP)
_tmpdir="${TMPDIR:-${TEMP:-${TMP:-$HOME/AppData/Local/Temp}}}"
export TMPDIR="$_tmpdir" TMP="$_tmpdir" TEMP="$_tmpdir"

# fzf (native Windows binary via winget)
if ! command -v fzf.exe &>/dev/null; then
    winget.exe install --id junegunn.fzf --accept-package-agreements --accept-source-agreements || true
fi

# Python 3.13+ (needed for AF_UNIX socket support on Windows)
winget.exe install --id Python.Python.3.13 --accept-package-agreements --accept-source-agreements || true

# CMake
winget.exe install --id Kitware.CMake --accept-package-agreements --accept-source-agreements || true

# Starship prompt
if ! command -v starship.exe &>/dev/null; then
    winget.exe install --id Starship.Starship --accept-package-agreements --accept-source-agreements || true
fi

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

# Ghostty shaders
if [ ! -d "$HOME/.config/ghostty/shaders" ]; then
    mkdir -p "$HOME/.config/ghostty"
    git clone https://github.com/sahaj-b/ghostty-cursor-shaders ~/.config/ghostty/shaders
fi
