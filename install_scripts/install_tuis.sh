#!/bin/bash
set -e # Exit if fail

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

# TODO: add yazi
#

# https://github.com/tsowell/wiremix
sudo apt install cargo libpipewire-0.3-dev pkg-config clang
cargo install wiremix
