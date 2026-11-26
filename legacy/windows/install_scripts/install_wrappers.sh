#!/bin/bash
set -e
source "$(dirname "$0")/helpers.sh"

# cursor-cli-wrapper uses Unix PTY APIs — skip on Windows for now
# cargo install --git=https://github.com/ofirgall/cursor-cli-wrapper --locked
echo "cursor-cli-wrapper skipped (Unix PTY APIs not supported on MSYS2)"
