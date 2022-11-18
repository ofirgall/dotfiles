#!/bin/bash

set -e # Exit if fail

sudo apt-get install -y awesome playerctl

AWESOME_CONFIG="$HOME/.config/awesome/"

# Plugins
git clone https://github.com/intrntbrn/awesomewm-vim-tmux-navigator $AWESOME_CONFIG/awesomewm-vim-tmux-navigator
git clone https://github.com/echuraev/keyboard_layout $AWESOME_CONFIG/keyboard_layout
git clone https://github.com/Veratil/awesome-retain $AWESOME_CONFIG/retain
git clone https://github.com/intrntbrn/smart_borders $AWESOME_CONFIG/smart_borders

# Libs
wget --directory-prefix=$AWESOME_CONFIG https://raw.githubusercontent.com/rxi/json.lua/master/json.lua

# awmtt runs xserver to debug your config
sudo apt-get install xserver-xephyr
sudo wget -O /usr/bin/awmtt https://raw.githubusercontent.com/mikar/awmtt/master/awmtt.sh
sudo chmod a+x /usr/bin/awmtt
