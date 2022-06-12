#!/bin/bash

set -e # Exit if fail

if [ ! -z "$1" ]; then
	COMMIT=$1
else
	COMMIT=nightly
fi

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

make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=$HOME/.local/ install -j
