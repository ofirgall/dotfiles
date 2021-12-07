#!/bin/bash

echo 'Installing Lsp Servers'

sudo apt install -y curl

# Clangd for C/CPP
sudo apt install -y clangd

# PYRIGHT
sudo apt install -y npm
sudo npm cache clean -f
sudo npm install -g n
sudo n stable

# Rustup + RLS
if ! command -v rustup &> /dev/null
then
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	source $HOME/.cargo/env
fi
rustup update
rustup component add rls rust-analysis rust-src
