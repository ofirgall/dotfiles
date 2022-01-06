#!/bin/bash

curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep -E "browser_download_url.*appimage\"" | cut -d : -f 2,3 | tr -d \" | wget -O $HOME/.local/bin/nvim -i -
chmod +x $HOME/.local/bin/nvim

# Install external dependecies (rg is in install_basic)
sudo apt install -w fd-find

# install vim-plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# install xkb-switch
sudo apt-get install -y libglib2.0-dev
rm -rf $HOME/.local/xkb-switch/
mkdir $HOME/.local/xkb-switch/
cd $HOME/.local/xkb-switch/
git clone https://github.com/lyokha/g3kb-switch
cd g3kb-switch
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make
sudo make install
