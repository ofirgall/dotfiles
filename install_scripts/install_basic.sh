#!/bin/bash

echo 'Installing Basic Libs'
sudo apt install -y xclip wget moreutils tmux ipython3 gnome-tweak-tool pcregrep sshfs python3-pip build-essential

sudo usermod -a -G dialout $USER
newgrp dialout
