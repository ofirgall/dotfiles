#!/bin/bash

set -e # Exit if fail
set -x

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

install_codelldb()
{
	unzip codelldb-x86_64-linux.vsix
	ln -f -s $HOME/.local/dap/codelldb/extension/adapter/codelldb $HOME/.local/bin/codelldb
}

# C/C++/Rust debug adapter
download_latest_release $HOME/.local/dap/codelldb vadimcn/vscode-lldb codelldb-x86_64-linux.vsix install_codelldb
