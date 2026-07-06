#!/bin/bash
set -e

eval "$(/opt/homebrew/bin/brew shellenv)"

if command -v tmux &>/dev/null; then
    echo "tmux already installed: $(tmux -V)"
    exit 0
fi

brew install tmux
