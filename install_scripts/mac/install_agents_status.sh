#!/bin/bash
set -e

REPO="$HOME/agents-status"
REMOTE="git@github.com:KoalaVim/agents-status.git"

if [ ! -d "$REPO" ]; then
    git clone "$REMOTE" "$REPO"
else
    echo "agents-status already cloned at $REPO"
fi

"$REPO/install.sh" core
"$REPO/install.sh" hooks cursor
"$REPO/install.sh" hooks codex
"$REPO/install.sh" cursor-cli-wrapper
