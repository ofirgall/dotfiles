#!/bin/bash
set -e

eval "$(/opt/homebrew/bin/brew shellenv)"

REPO="$HOME/agents-status"

brew install vjeantet/tap/alerter

if command -v uv >/dev/null 2>&1; then
    uv tool install "$REPO/core" --force
else
    "$REPO/install.sh" core
fi
"$REPO/install.sh" hooks cursor
"$REPO/install.sh" hooks codex
"$REPO/install.sh" cursor-cli-wrapper
