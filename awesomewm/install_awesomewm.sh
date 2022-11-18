#!/bin/bash

set -e # Exit if fail

sudo apt-get install -y awesome playerctl

AWESOME_CONFIG="$HOME/.config/awesome/"

# Plugins
git clone --depth=1 https://github.com/intrntbrn/awesomewm-vim-tmux-navigator $AWESOME_CONFIG/awesomewm-vim-tmux-navigator
git clone --depth=1 https://github.com/echuraev/keyboard_layout $AWESOME_CONFIG/keyboard_layout
git clone --depth=1 https://github.com/Veratil/awesome-retain $AWESOME_CONFIG/retain
git clone --depth=1 https://github.com/intrntbrn/smart_borders $AWESOME_CONFIG/smart_borders
git clone --depth=1 https://github.com/streetturtle/awesome-wm-widgets $AWESOME_CONFIG/awesome-wm-widgets

# Install `sp` binary for spotify-widget
git clone https://gist.github.com/fa6258f3ff7b17747ee3.git /tmp/sp
chmod +x /tmp/sp/sp
sudo mv /tmp/sp/sp /usr/local/bin/

# Arc icons
git clone --depth=1 --branch=Arc-ICONS git@github.com:rtlewis88/rtl88-Themes.git /tmp/icons
sudo mkdir /usr/share/icons/Arc/
sudo mv /tmp/icons/Arc-ICONS/* /usr/share/icons/Arc/

# Libs
wget --directory-prefix=$AWESOME_CONFIG https://raw.githubusercontent.com/rxi/json.lua/master/json.lua

# awmtt runs xserver to debug your config
sudo apt-get install xserver-xephyr
sudo wget -O /usr/bin/awmtt https://raw.githubusercontent.com/mikar/awmtt/master/awmtt.sh
sudo chmod a+x /usr/bin/awmtt
