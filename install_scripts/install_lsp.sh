#!/bin/bash

echo 'Installing Lsp Servers & Helpers'

# ripgrep is nessecary too but we install it in install_basic because of a bug
sudo apt install -y curl universal-ctags

# Clangd for C/CPP
sudo apt install -y clangd

# Node
sudo apt install -y npm
sudo npm cache clean -f
sudo npm install -g n
sudo n stable

# PYRIGHT
sudo npm install -g pyright

# vim-language
sudo npm install -g vim-language-server
sudo npm install -g bash-language-server

# Rustup + RLS + rust-analyzer
if ! command -v rustup &> /dev/null
then
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	source $HOME/.cargo/env
fi
rustup update
rustup component add rls rust-analysis rust-src
rustup +nightly component add rust-analyzer-preview
ln -s $HOME/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/rust-analyzer $HOME/.local/bin/rust-analyzer

# Java :(
sudo apt install -y maven default-jdk

# Lua
rm -rf $HOME/.local/lua-server
mkdir $HOME/.local/lua-server
curl -s https://api.github.com/repos/sumneko/lua-language-server/releases/latest | grep "browser_download_url.*linux-x64" | cut -d : -f 2,3 | tr -d \" | wget -P $HOME/.local/lua-server/ -qi -
tar -xf $HOME/.local/lua-server/lua-language-server-*.tar.gz -C $HOME/.local/lua-server/
ln -s $HOME/.local/lua-server/bin/lua-language-server $HOME/.local/bin/lua-language-server

# CMake
python3 -m pip install cmake-language-server
