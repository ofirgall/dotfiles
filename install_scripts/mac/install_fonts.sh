#!/bin/bash
set -e

eval "$(/opt/homebrew/bin/brew shellenv)"

brew install --cask \
    font-caskaydia-cove-nerd-font \
    font-ubuntu-mono-nerd-font \
    font-jetbrains-mono-nerd-font \
    font-iosevka-term-nerd-font \
    font-commit-mono-nerd-font \
    font-0xproto-nerd-font \
    font-recursive-mono-nerd-font \
    font-maple-mono-nf

# Remove Caskaydia custom italic fonts
rm -f ~/Library/Fonts/Caskaydia*Italic*
