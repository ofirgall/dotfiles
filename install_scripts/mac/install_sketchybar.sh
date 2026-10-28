#!/bin/bash
set -e

eval "$(/opt/homebrew/bin/brew shellenv)"

if brew list sketchybar &>/dev/null; then
    echo "SketchyBar already installed"
else
    brew install FelixKratz/formulae/sketchybar
fi

# App icon font used for workspace labels (helpers/icon_map.sh must match its version)
if brew list --cask font-sketchybar-app-font &>/dev/null; then
    echo "sketchybar-app-font already installed"
else
    brew install --cask font-sketchybar-app-font
fi

brew services start sketchybar
