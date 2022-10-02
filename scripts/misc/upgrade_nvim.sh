#!/bin/bash

set -e # Exit if fail

if [ ! -z "$1" ]; then
	COMMIT=$1
else
	COMMIT=nightly
fi

echo "Checking github.com is accessible"
ping -c 1 github.com

if command -v nvim &> /dev/null
then
	echo "==== Current NVIM ===="
	nvim --version
	echo "======================"
fi

echo "COMMIT: $COMMIT"
NVIM_PATH=$HOME/.local/nvim-nightly

mkdir -p $NVIM_PATH
cd $NVIM_PATH

rm -rf neovim

git clone https://github.com/neovim/neovim.git -b $COMMIT --depth=1 --single-branch
cd neovim

# Remove runtime to allow neovim install clean runtime directory
rm -rf $HOME/.local/share/nvim/runtime

# Build and install neovim
make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=$HOME/.local/ install -j
