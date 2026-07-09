#!/bin/bash
set -e
source "$(dirname "$0")/helpers.sh"

if ! winget.exe list --id GitHub.cli 2>/dev/null | grep -q "GitHub CLI"; then
    echo "Installing GitHub CLI..."
    winget.exe install --id GitHub.cli --accept-package-agreements --accept-source-agreements
fi

gh extension install dlvhdr/gh-dash || true
gh extension install dlvhdr/gh-enhance || true
gh extension install ofirgall/gh-markdown-preview || true
