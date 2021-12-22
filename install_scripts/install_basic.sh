#!/bin/bash

echo 'Installing Basic Libs'
sudo apt install -y xclip wget moreutils tmux ipython3 gnome-tweak-tool pcregrep sshfs python3-pip build-essential alacritty fzf daemon

# Install bat & rg
sudo apt install -y -o Dpkg::Options::="--force-overwrite" bat ripgrep
mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat

sudo usermod -a -G dialout $USER
newgrp dialout
