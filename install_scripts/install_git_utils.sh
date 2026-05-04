#!/bin/bash
set -e # Exit if fail

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

# github tui
gh extension install dlvhdr/gh-dash

# github actions tui
gh extension install dlvhdr/gh-enhance

# markdown preview
gh extension install yusukebe/gh-markdown-preview
