#!/bin/bash

set -e # Exit if fail

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

install_wsl32yank()
{
	unzip win32yank-x86.zip
	mv win32yank.exe $HOME/.local/bin
}

# Install wsl32yank
download_latest_release /tmp/win32yank/ equalsraf/win32yank win32yank-x86.zip install_wsl32yank
