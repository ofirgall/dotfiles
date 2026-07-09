#!/bin/bash
set -e
source "$(dirname "$0")/helpers.sh"

REPO="$HOME/agents-status"
REMOTE="git@github.com:KoalaVim/agents-status.git"

if [ ! -d "$REPO" ]; then
    git clone "$REMOTE" "$REPO"
else
    echo "agents-status already cloned at $REPO"
fi

if command -v uv >/dev/null 2>&1; then
    uv tool install "$REPO/core" --force
else
    "$REPO/install.sh" core
fi
"$REPO/install.sh" hooks cursor
"$REPO/install.sh" hooks codex
# cursor-cli-wrapper uses Unix PTY APIs — skip on Windows
