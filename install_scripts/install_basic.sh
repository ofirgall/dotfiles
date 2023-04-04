#!/bin/bash

set -e # Exit if fail

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

if $NO_SUDO; then
	# Install fzf
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf

	~/.fzf/install --no-update-rc
	python3 -m pip install -r scripts/requirements.txt --user
	exit 0
fi

# Add 3rd party repos
sudo add-apt-repository ppa:git-core/ppa -y # newer git, requires update and upgrade git package

echo 'Installing Basic Libs'
sudo apt install -y wget moreutils ipython3 pcregrep python3-pip build-essential fzf daemon curl cmake btop toilet

python3 -m pip install brotab ranger-fm shell-gpt mkdocs mkdocs-material
$HOME/.local/bin/bt install

# Install bat & rg
sudo apt install -y -o Dpkg::Options::="--force-overwrite" bat ripgrep
mkdir -p ~/.local/bin
ln -f -s /usr/bin/batcat ~/.local/bin/bat

# Install fd-find
sudo apt install -y fd-find
ln -f -s $(which fdfind) ~/.local/bin/fd

if ! $IS_REMOTE; then
	sudo apt install -y xclip
fi

# Rustup
if ! command -v rustup &> /dev/null
then
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
	source $HOME/.cargo/env
fi
rustup update

cargo install difftastic
cargo install du-dust
cargo install git-delta
cargo install jless
cargo install igrep
cargo install --locked broot
if ! $IS_REMOTE; then
	# Install latest alacritty
	sudo apt install -y cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3
	cargo install --git=https://github.com/alacritty/alacritty
	sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator $HOME/.cargo/bin/alacritty 100

	# General utils
	sudo apt install -y gh
fi

# Install wsl utils
if $WSL; then
	$CURRENT_DIR/install_wsl_utils.sh
fi

# Install npm
sudo apt install -y npm
sudo npm cache clean -f
sudo npm install -g n
sudo n stable

if ! $IS_REMOTE; then
	install_bluetuith()
	{
		tar -xf *.tar.gz
		chmod +x bluetuith
		mv bluetuith $HOME/.local/bin/
	}

	download_latest_release /tmp/bluetuith/ darkhz/bluetuith Linux_x86_64 install_bluetuith
fi

# Set npm install prefix to user
mkdir -p "$HOME/.npm-packages"
npm config set prefix "$HOME/.npm-packages"

# Must be at the end
sudo usermod -a -G dialout $USER
newgrp dialout
