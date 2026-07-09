#!/bin/bash
set -e
source "$(dirname "$0")/helpers.sh"

if command -v kanata &>/dev/null; then
    echo "Kanata already installed"
    exit 0
fi

echo "Installing Kanata..."
cargo install kanata
