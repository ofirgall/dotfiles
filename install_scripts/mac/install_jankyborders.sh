#!/bin/bash
set -e

eval "$(/opt/homebrew/bin/brew shellenv)"

if brew list borders &>/dev/null; then
    echo "JankyBorders already installed"
else
    brew install FelixKratz/formulae/borders
fi

brew services start borders
