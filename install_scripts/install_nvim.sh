#!/bin/bash

curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep -E "browser_download_url.*appimage\"" | cut -d : -f 2,3 | tr -d \" | wget -O $HOME/.local/bin/nvim -i -
chmod +x $HOME/.local/bin/nvim

# Install external dependecies (rg is in install_basic)
sudo apt install -y fd-find

# install packer
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 $HOME/.local/share/nvim/site/pack/packer/start/packer.nvim

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

# For upgrade_nvim.sh
sudo apt install -y gettext libtermkey-dev
