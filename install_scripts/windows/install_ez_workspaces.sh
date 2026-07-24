#!/bin/bash
set -e
source "$(dirname "$0")/helpers.sh"

if command -v ez &>/dev/null; then
    echo "ez-workspaces already installed"
    exit 0
fi

CARGO_NET_GIT_FETCH_WITH_CLI=true cargo install --git https://github.com/KoalaVim/ez-workspaces
