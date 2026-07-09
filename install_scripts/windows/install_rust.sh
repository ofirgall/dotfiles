#!/bin/bash
set -e

export PATH="$HOME/.cargo/bin:$PATH"

if command -v cargo &>/dev/null; then
    echo "Rust already installed: $(rustc --version)"
    exit 0
fi

echo "Installing Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
export PATH="$HOME/.cargo/bin:$PATH"

echo "Rust installed: $(rustc --version)"
