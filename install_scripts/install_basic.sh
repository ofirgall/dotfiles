#!/bin/bash

echo 'Installing Basic Libs'
sudo apt install -y xclip wget moreutils tmux ipython3 gnome-tweak-tool

sudo usermod -a -G dialout $USER
newgrp dialout
