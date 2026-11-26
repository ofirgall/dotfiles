#!/bin/bash
set -e
source "$(dirname "$0")/helpers.sh"

echo "Installing MSYS2 packages..."

# MSYS2 native packages
pacman -S --noconfirm --needed \
    base-devel \
    zsh \
    tmux \
    python \
    python-pip \
    man-db \
    wget \
    curl \
    unzip \
    tar \
    openssh

# MinGW GCC (needed for cargo builds with cc crate)
pacman -S --noconfirm --needed mingw-w64-x86_64-gcc

# CLI tools from ucrt64/mingw64 repos
pacman -S --noconfirm --needed \
    mingw-w64-ucrt-x86_64-neovim \
    mingw-w64-ucrt-x86_64-ripgrep \
    mingw-w64-ucrt-x86_64-fd \
    mingw-w64-ucrt-x86_64-fzf \
    mingw-w64-ucrt-x86_64-jq \
    mingw-w64-ucrt-x86_64-bat

# uv (Python package manager, used by agents-status)
if ! command -v uv &>/dev/null; then
    echo "Installing uv..."
    cargo install uv --locked || winget.exe install --id astral-sh.uv --accept-package-agreements --accept-source-agreements 2>/dev/null || echo "Warning: could not install uv"
fi

# Set zsh as default MSYS2 shell
if ! grep -q "db_shell:.*/zsh" /etc/nsswitch.conf 2>/dev/null; then
    if sed -i 's|db_shell:.*|db_shell: /usr/bin/zsh|' /etc/nsswitch.conf 2>/dev/null; then
        echo "Set zsh as default MSYS2 shell"
    else
        echo "Warning: could not update /etc/nsswitch.conf (run as admin to set zsh as default shell)"
    fi
fi
