#!/bin/bash
set -e

eval "$(/opt/homebrew/bin/brew shellenv)"

if ! command -v tmux &>/dev/null; then
    brew install tmux
fi

echo "tmux: $(tmux -V)"

# Install TPM
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    echo "TPM already installed"
fi

# Plugin dependencies
brew install python3
pip3 install --break-system-packages --user libtmux
