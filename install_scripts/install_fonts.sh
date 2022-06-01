#!/bin/bash

set -e # Exit if fail

mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts

download_font()
{
	font=$1

	if ls | grep $font; then
		return
	fi

	wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/$font.zip
	unzip -o $font.zip
	# dont remove .zip
}

download_font CascadiaCode
download_font UbuntuMono

fc-cache -f -v
