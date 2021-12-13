#!/bin/bash

sudo apt install -y zsh

# Change default shell
if [ ! $0 = "-zsh" ]; then
  echo 'Changing default shell to zsh'
  sudo chsh -s /bin/zsh
else
  echo 'Already using zsh'
fi

