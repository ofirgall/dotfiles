#!/bin/bash
set -e

REPO="$HOME/agents-status"

if command -v uv >/dev/null 2>&1; then
    uv tool install "$REPO/core" --force
else
    "$REPO/install.sh" core
fi
"$REPO/install.sh" hooks all
"$REPO/install.sh" cursor-cli-wrapper
