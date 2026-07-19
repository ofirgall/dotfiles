#!/bin/bash
set -e
source "$(dirname "$0")/helpers.sh"

# https://github.com/modem-dev/hunk
npm i -g hunkdiff

# https://github.com/jnsahaj/lumen
cargo install lumen

# https://github.com/wtnqk/ftdv
cargo install ftdv
