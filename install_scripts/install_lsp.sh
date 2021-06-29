#!/bin/bash

echo 'Installing Lsp Servers'

# Clangd for C/CPP
sudo apt install -y clangd-10
cd /usr/bin
sudo ln -s clangd-10 clangd

# PYLSP
sudo apt install -y python3.8-virtualenv

# PYRIGHT
sudo apt install -y npm
sudo npm cache clean -f
sudo npm install -g n
sudo n stable

# Rustup + RLS
if ! command -v rustup &> /dev/null
then
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi
rustup update
rustup component add rls rust-analysis rust-src
