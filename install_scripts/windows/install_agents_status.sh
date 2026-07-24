#!/bin/bash
set -e
source "$(dirname "$0")/helpers.sh"

# On Windows, "python3" is a WindowsApps stub that just opens the Store.
# The real interpreter is "python.exe". Create a shim so agents-status's
# install.sh (which calls python3) finds the real one.
if command -v python &>/dev/null && ! python3 --version &>/dev/null 2>&1; then
    _shim_dir="$(mktemp -d)"
    printf '#!/bin/bash\nexec python "$@"\n' > "$_shim_dir/python3"
    chmod +x "$_shim_dir/python3"
    export PATH="$_shim_dir:$PATH"
fi

REPO="$HOME/agents-status"
REMOTE="git@github.com:KoalaVim/agents-status.git"

if [ ! -d "$REPO" ]; then
    git clone "$REMOTE" "$REPO"
else
    echo "agents-status already cloned at $REPO"
fi

if command -v uv >/dev/null 2>&1; then
    uv tool install "$REPO/core" --force
else
    "$REPO/install.sh" core
fi
"$REPO/install.sh" hooks all
# cursor-cli-wrapper uses Unix PTY APIs — skip on Windows
# "$REPO/install.sh" cursor-cli-wrapper
