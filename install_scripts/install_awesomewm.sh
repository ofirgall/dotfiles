#!/bin/bash

set -e # Exit if fail

sudo apt-get install -y awesome

# Plugins
git clone https://github.com/intrntbrn/awesomewm-vim-tmux-navigator ~/.config/awesome/awesomewm-vim-tmux-navigator
