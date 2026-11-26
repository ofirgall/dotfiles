#!/bin/bash
set -e
source "$(dirname "$0")/helpers.sh"

# https://github.com/modem-dev/hunk
if command -v npm &>/dev/null; then
    npm i -g hunkdiff
else
    echo "Warning: npm not found, skipping hunkdiff (install Node.js first)"
fi

# https://github.com/jnsahaj/lumen
cargo install lumen

# https://github.com/wtnqk/ftdv
cargo install ftdv
