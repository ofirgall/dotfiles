#!/bin/bash
set -e

eval "$(/opt/homebrew/bin/brew shellenv)"

brew install gh

gh extension install dlvhdr/gh-dash
gh extension install dlvhdr/gh-enhance
gh extension install ofirgall/gh-markdown-preview

if brew list --cask markdown-preview &>/dev/null; then
    echo "Markdown Preview already installed"
else
    brew install --cask markdown-preview
fi
