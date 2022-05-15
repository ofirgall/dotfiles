#!/bin/bash

set -e # Exit if fail

sudo apt install -y libclang-dev llvm

cd ~/.local/share
git clone https://github.com/p-ranav/fccf
cd fccf

# Build
cmake -S . -B build -D CMAKE_BUILD_TYPE=Release
cmake --build build

# Install
sudo cmake --install build
