#!/bin/bash
set -e

if command -v brew &>/dev/null || [ -x /opt/homebrew/bin/brew ]; then
    echo "Homebrew already installed"
    exit 0
fi

echo "Installing Homebrew..."
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add brew to PATH for the rest of this session
eval "$(/opt/homebrew/bin/brew shellenv)"

echo "Homebrew installed: $(brew --version | head -1)"
