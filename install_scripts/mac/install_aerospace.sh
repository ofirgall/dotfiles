#!/bin/bash
set -e

eval "$(/opt/homebrew/bin/brew shellenv)"

if [ ! -d "/Applications/AeroSpace.app" ]; then
    brew install --cask nikitabobko/tap/aerospace
fi

SCRIPTS_DIR="$(dirname "$0")/../../aerospace-scripts"
if command -v cargo &>/dev/null; then
    echo "Building and installing aerospace-scripts..."
    make -C "$SCRIPTS_DIR" install
else
    echo "WARNING: cargo not found, skipping aerospace-scripts build"
fi

SWITCHER_DIR="$(dirname "$0")/../../aerospace-switcher"
if command -v swift &>/dev/null; then
    echo "Building and installing aerospace-switcher..."
    make -C "$SWITCHER_DIR" install
else
    echo "WARNING: swift not found, skipping aerospace-switcher build"
fi
