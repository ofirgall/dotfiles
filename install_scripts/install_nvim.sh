#!/bin/bash

sudo snap install nvim --classic

# Install external dependecies (rg is in install_basic)
sudo apt install -w fd-find

# install vim-plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
