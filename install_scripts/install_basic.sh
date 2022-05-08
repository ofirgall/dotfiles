#!/bin/bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

python3 -m pip install -r scripts/requirements.txt --user

if $NO_SUDO; then
	# Install fzf
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf

	~/.fzf/install --no-update-rc
	exit 0
fi

echo 'Installing Basic Libs'
sudo apt install -y wget moreutils tmux ipython3 pcregrep python3-pip build-essential fzf daemon

# Install bat & rg
sudo apt install -y -o Dpkg::Options::="--force-overwrite" bat ripgrep
mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat

if ! $IS_REMOTE; then
	sudo apt install -y xclip gnome-tweak-tool alacritty
fi

sudo usermod -a -G dialout $USER
newgrp dialout

# Instlal tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Rustup
if ! command -v rustup &> /dev/null
then
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	source $HOME/.cargo/env
fi
rustup update

cargo install difftastic
cargo install du-dust
