#!/usr/bin/env bash

set -e

# log=/tmp/test-notify.log
# exec >>"$log" 2>&1
# echo "[$(date +%T)] on-finish pane=$TMUX_NOTIFY_PANE_ID session=$TMUX_NOTIFY_SESSION_ID window=$TMUX_NOTIFY_WINDOW_ID exit=$TMUX_NOTIFY_EXIT_STATUS"

window="${TMUX_NOTIFY_SESSION_NAME}:@${TMUX_NOTIFY_WINDOW_ID}"
# echo "  target: $window"

tmux set-option -wu -t "$window" @monitor-status
tmux set-option -wu -t "$window" @window_color

"$HOME/agents-status/tmux/scripts/refresh_dim_colors.sh"

if [[ "$OSTYPE" == darwin* ]]; then
    /opt/homebrew/bin/python3.14 "$HOME/agents-status/statusbar/run.py" &
elif [[ -n "$MSYSTEM" ]]; then
    :
else
    "$HOME/.config/hypr/UserScripts/RenameWorkspaces.py"
fi
