#!/bin/bash

set -e # Exit if fail

sudo usermod -a -G input $USER
newgrp input
sudo apt-get install -y libinput-tools ruby libevdev-dev ruby-dev build-essential
sudo gem install fusuma revdev bundler fusuma-plugin-sendkey
