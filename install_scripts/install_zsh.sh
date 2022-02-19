#!/bin/bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

if $NO_SUDO; then
	exit 0
fi

sudo apt install -y zsh

# Change default shell
if [ ! $0 = "-zsh" ]; then
  echo 'Changing default shell to zsh'
  sudo chsh -s /bin/zsh
else
  echo 'Already using zsh'
fi

