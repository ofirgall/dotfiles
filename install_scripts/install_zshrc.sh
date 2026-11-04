#!/bin/bash
# ~/.zshrc is a local, untracked file that sources the repo's entrypoint, so
# tools that append to ~/.zshrc don't modify the repo.
set -e

ZSHRC="$HOME/.zshrc"
SOURCE_LINE='source "$HOME/.zsh-conf/entrypoint.zsh"'

# Older installs symlinked ~/.zshrc to entrypoint.zsh
[[ -L "$ZSHRC" ]] && rm "$ZSHRC"
touch "$ZSHRC"

if ! grep -qxF "$SOURCE_LINE" "$ZSHRC"; then
    tmp="$(mktemp)"
    { echo "$SOURCE_LINE"; cat "$ZSHRC"; } > "$tmp"
    cat "$tmp" > "$ZSHRC"
    rm "$tmp"
fi
