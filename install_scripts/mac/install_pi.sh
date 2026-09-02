#!/bin/bash
set -e

eval "$(/opt/homebrew/bin/brew shellenv)"

if command -v pi &>/dev/null; then
    echo "pi already installed"
else
    echo "Installing pi coding agent..."
    npm install -g --ignore-scripts @earendil-works/pi-coding-agent
fi

# Install herdr integration
herdr integration install pi 2>/dev/null || true

# Install packages (pi install is idempotent)
pi install npm:pi-subagents 2>/dev/null || true
pi install https://github.com/wishx127/pi-tokyo-night 2>/dev/null || true

# Install pi-skills
if [ ! -d "$HOME/.pi/agent/skills/pi-skills" ]; then
    git clone https://github.com/badlogic/pi-skills "$HOME/.pi/agent/skills/pi-skills"
fi
