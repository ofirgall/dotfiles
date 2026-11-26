#!/bin/bash
set -e
source "$(dirname "$0")/helpers.sh"

echo "tmux: $(tmux -V)"

# Install TPM
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    echo "TPM already installed"
fi

# Plugin dependencies
pip3 install --break-system-packages --user libtmux
