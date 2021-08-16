#!/bin/bash

echo "Installing Sublime/Smerge"
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

sudo apt-get update
sudo apt-get install sublime-text sublime-merge -y
