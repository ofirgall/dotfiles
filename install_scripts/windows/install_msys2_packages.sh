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
    mingw-w64-x86_64-fzf \
    mingw-w64-x86_64-jq \
    mingw-w64-x86_64-bat \
    mingw-w64-x86_64-btop

# Set zsh as default MSYS2 shell
if ! grep -q "db_shell:.*/zsh" /etc/nsswitch.conf 2>/dev/null; then
    sed -i 's|db_shell:.*|db_shell: /usr/bin/zsh|' /etc/nsswitch.conf
    echo "Set zsh as default MSYS2 shell"
fi
