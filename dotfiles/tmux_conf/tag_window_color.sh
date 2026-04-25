#!/bin/bash
# Usage: tag_window_color.sh <color> <window_id>
# Resolves <color> to hex via dim_color.sh, then tags the window with:
#   @window_color        = bright hex
#   @window_color_active = 50%-dim hex
color="$1"
wid="$2"
dir="$(dirname "$0")"
bright=$("$dir/dim_color.sh" "$color" 1.0)
dim=$("$dir/dim_color.sh" "$color" 0.5)
tmux setw -t "$wid" @window_color        "$bright"
tmux setw -t "$wid" @window_color_active "$dim"
