#!/usr/bin/env bash

log=/tmp/test-notify.log
exec >>"$log" 2>&1
echo "[$(date +%T)] on-finish pane=$TMUX_NOTIFY_PANE_ID session=$TMUX_NOTIFY_SESSION_ID window=$TMUX_NOTIFY_WINDOW_ID exit=$TMUX_NOTIFY_EXIT_STATUS"

window="${TMUX_NOTIFY_SESSION_NAME}:@${TMUX_NOTIFY_WINDOW_ID}"
echo "  target: $window"

set -x
tmux set-option -wu -t "$window" @monitor-in-status
tmux set-option -wu -t "$window" @window_color

"$HOME/.tmux_conf/refresh_dim_colors.sh"
"$HOME/.config/hypr/UserScripts/RenameWorkspaces.py"
