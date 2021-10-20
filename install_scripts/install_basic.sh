#!/bin/bash

echo 'Installing Basic Libs'
sudo apt install -y xclip wget moreutils tmux ipython3

sudo usermod -a -G dialout $USER
newgrp dialout
