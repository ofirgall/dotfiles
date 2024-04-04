#!/bin/bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
set -e # Exit if fail

sudo apt-get install -y awesome playerctl i3lock-fancy xautolock pasystray

AWESOME_CONFIG="$HOME/.config/awesome/"

clone() {
	# $1 github repo
	# $2 dest
	if [ -d $2 ]; then
		return
	fi

	git clone --depth=1 https://github.com/$1 $2
}

clone_awesome() {
	# $1 github shorthand repo
	# $2 dest
	clone $1 $AWESOME_CONFIG/$2
}

# Plugins
clone_awesome ofirgall/awesomewm-vim-tmux-navigator awesomewm-vim-tmux-navigator # fork
clone_awesome echuraev/keyboard_layout keyboard_layout
clone_awesome Veratil/awesome-retain retain
clone_awesome intrntbrn/smart_borders smart_borders
clone_awesome streetturtle/awesome-wm-widgets awesome-wm-widgets
clone_awesome pltanton/net_widgets.git net_widgets

# Install `sp` binary for spotify-widget
rm -rf /tmp/sp
git clone https://gist.github.com/fa6258f3ff7b17747ee3.git /tmp/sp
chmod +x /tmp/sp/sp
sudo mv /tmp/sp/sp /usr/local/bin/

# Arc icons
rm -rf /tmp/icons
git clone --depth=1 --branch=Arc-ICONS git@github.com:rtlewis88/rtl88-Themes.git /tmp/icons
rm -rf /usr/share/icons/Arc/
sudo mkdir -p /usr/share/icons/Arc/
sudo mv /tmp/icons/Arc-ICONS/* /usr/share/icons/Arc/

# Libs
wget --directory-prefix=$AWESOME_CONFIG https://raw.githubusercontent.com/rxi/json.lua/master/json.lua

# awmtt runs xserver to debug your config
sudo apt-get install xserver-xephyr
sudo wget -O /usr/bin/awmtt https://raw.githubusercontent.com/mikar/awmtt/master/awmtt.sh
sudo chmod a+x /usr/bin/awmtt

# autorandr
python3 -m pip install autorandr

# audio control (aliased to `audio`|`sound`)
sudo apt-get install -y pavucontrol
sudo rm -f /etc/pulse/default.pa
sudo ln -s $CURRENT_DIR/../system/pulseaudio.pa /etc/pulse/default.pa
pulseaudio -k

# install systray apps for bluetooth and such
sudo apt-get install -y pavucontrol blueman flameshot

# copyq for clipboard history
sudo apt-get -y install copyq copyq-plugins
