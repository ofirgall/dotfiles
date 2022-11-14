#!/bin/bash

set -e # Exit if fail

sudo apt-get install -y awesome playerctl

# Plugins
git clone https://github.com/intrntbrn/awesomewm-vim-tmux-navigator ~/.config/awesome/awesomewm-vim-tmux-navigator
git clone https://github.com/echuraev/keyboard_layout ~/.config/awesome/keyboard_layout
