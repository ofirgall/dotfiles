#!/bin/bash

sudo usermod -a -G input $USER
newgrp input
sudo apt-get install -y libinput-tools ruby libevdev-dev ruby-dev build-essential
sudo gem install fusuma revdev bundler fusuma-plugin-sendkey
gsettings set org.gnome.desktop.peripherals.touchpad send-events enabled
