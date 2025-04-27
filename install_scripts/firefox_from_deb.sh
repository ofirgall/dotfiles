#!/bin/bash

set -e # Exit if fail

if ! sudo snap list | grep "firefox"; then
	echo "No firefox from snap"
	exit
fi

sudo snap remove firefox

sudo add-apt-repository -y ppa:mozillateam/ppa

echo '
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
' | sudo tee /etc/apt/preferences.d/mozilla-firefox

echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";' | sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox

sudo apt update || true
sudo apt install -y firefox
