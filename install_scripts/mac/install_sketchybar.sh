#!/bin/bash
set -e

eval "$(/opt/homebrew/bin/brew shellenv)"

if brew list sketchybar &>/dev/null; then
    echo "SketchyBar already installed"
else
    brew install FelixKratz/formulae/sketchybar
fi

brew services start sketchybar
