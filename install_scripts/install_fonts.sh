#!/bin/bash

set -e # Exit if fail

mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts

download_font()
{
	if [[ "$1" == http* ]]; then
		url="$1"
		archive="${url##*/}"
	else
		archive="$1.tar.xz"
		url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/$archive"
	fi

	wget -O "$archive" "$url"

	case "$archive" in
		*.tar.xz) tar xf "$archive" ;;
		*.zip)    unzip -o "$archive" ;;
	esac

	rm -f "$archive"
}

download_font CascadiaCode
download_font UbuntuMono
download_font JetBrainsMono
download_font IosevkaTerm
download_font CommitMono
download_font 0xProto
download_font Recursive
download_font https://github.com/subframe7536/maple-font/releases/download/v7.9/MapleMonoNormalNL-TTF.zip

# Remove Caskaydia custom italic fonts
rm -f Caskaydia*Italic*

fc-cache -f -v
