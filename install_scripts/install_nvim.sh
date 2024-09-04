#!/bin/bash

set -e # Exit if fail

# To build neovim
sudo apt-get install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen

# numToStr/lemmy-help
cargo install lemmy-help --features=cli

# https://code.sitosis.com/rudism/telescope-dict.nvim
sudo apt-get install -y dictd dict-wn
wget http://archive.ubuntu.com/ubuntu/pool/main/d/dict-moby-thesaurus/dict-moby-thesaurus_1.0-6.4_all.deb -P ~/Downloads
sudo dpkg -i ~/Downloads/dict-moby-thesaurus_1.0-6.4_all.deb

# toppair/peek.nvim
curl -fsSL https://deno.land/install.sh | sh
ln -s -f $HOME/.deno/bin/deno $HOME/.local/bin/deno

# https://gitlab.com/itaranto/plantuml.nvim
 sudo apt-get install -y plantuml imv feh

if -d ~/.local/share/nvim; then
	echo "Skipping nvim install"
else
	~/dotfiles_scripts/misc/upgrade_nvim.sh stable
fi
