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

# macOS ships ancient terminfo without extended capabilities (Smulx, Setulc).
# Compile Homebrew's tmux-256color into ~/.terminfo so undercurl works.
/opt/homebrew/opt/ncurses/bin/infocmp -x tmux-256color > /tmp/tmux-256color.terminfo
/opt/homebrew/opt/ncurses/bin/tic -x -o ~/.terminfo /tmp/tmux-256color.terminfo
rm /tmp/tmux-256color.terminfo

# Generate default keybindings (used by reload to cleanly unbind plugin keys)
tmux -L _defaults -f /dev/null start-server \; list-keys \; kill-server > ~/.tmux/default-keys.conf

# Plugin dependencies
brew install python3
pip3 install --break-system-packages --user libtmux
