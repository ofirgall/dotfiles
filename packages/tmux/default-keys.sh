# ~/.tmux/default-keys.conf: tmux's stock bindings
set -euo pipefail
mkdir -p "$HOME/.tmux"
tmux -L _defaults -f /dev/null start-server \; list-keys \; kill-server > "$HOME/.tmux/default-keys.conf"
