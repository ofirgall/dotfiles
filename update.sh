#!/bin/bash

sudo apt update && sudo apt upgrade -y
sudo npm -g update
sudo snap refresh
rustup update
python3 -m pip install pip --upgrade
python3 -m pip install -r dotfiles_scripts/requirements.txt --user
