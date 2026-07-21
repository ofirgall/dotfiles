#!/bin/bash
set -e

eval "$(/opt/homebrew/bin/brew shellenv)"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Brew packages
brew install yq yj bat ripgrep fd fzf fx btop jq uv

# Cargo packages
cargo install difftastic
cargo install du-dust
cargo install git-delta
cargo install jless
cargo install igrep
cargo install bottom --locked
cargo install tuitab
cargo install lemmy-help --features=cli

# Python packages
pip3 install --break-system-packages libtmux brotab

# Ghostty shaders
if [ ! -d "$HOME/.config/ghostty/shaders" ]; then
    git clone https://github.com/ofirgall/ghostty-cursor-shaders ~/.config/ghostty/shaders
fi
