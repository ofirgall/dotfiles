#!/bin/bash
set -e

if command -v brew &>/dev/null; then
    echo "Homebrew already installed: $(brew --version | head -1)"
    exit 0
fi

echo "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add brew to PATH for the rest of this session
eval "$(/opt/homebrew/bin/brew shellenv)"

echo "Homebrew installed: $(brew --version | head -1)"
