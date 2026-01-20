#!/bin/bash
set -e # Exit if fail

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

build_tmux()
{
	tar -xf *.tar.gz
	rm *.tar.gz
	cd tmux-*

	./configure && make
	sudo make install
}

# For compile
sudo apt-get install -y libevent-dev libncurses-dev bison byacc

# For plugins
sudo apt-get install -y ruby
python3 -m pip install  --break-system-packages --user libtmux
download_latest_release /tmp/tmux tmux/tmux *\.tar\.gz build_tmux

# Install tpm
rm -rf ~/.tmux/plugins/tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
