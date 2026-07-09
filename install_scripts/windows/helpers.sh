#!/bin/bash

export MSYS=winsymlinks:nativestrict

# Add Windows native tools to PATH for MSYS2 bash scripts
# Order matters: MSYS2 tools first, then cargo, then WindowsApps last
export PATH="/ucrt64/bin:/mingw64/bin:$HOME/.cargo/bin:$PATH"
export PATH="$PATH:$HOME/AppData/Local/Microsoft/WindowsApps"
