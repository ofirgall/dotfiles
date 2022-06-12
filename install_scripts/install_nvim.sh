#!/bin/bash

set -e # Exit if fail

sudo apt-get install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen

~/dotfiles_scripts/misc/upgrade_nvim.sh stable
git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
