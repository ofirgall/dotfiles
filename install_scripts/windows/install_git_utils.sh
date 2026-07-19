#!/bin/bash
set -e
source "$(dirname "$0")/helpers.sh"

if ! command -v gh &>/dev/null; then
    echo "Installing GitHub CLI..."
    winget.exe install --id GitHub.cli --accept-package-agreements --accept-source-agreements
fi

gh extension install dlvhdr/gh-dash 2>/dev/null || true
gh extension install dlvhdr/gh-enhance 2>/dev/null || true
gh extension install ofirgall/gh-markdown-preview 2>/dev/null || true
