#!/bin/bash
# Refresh workspace cache + sketchybar when a new window appears.
# This ensures workspaces with newly opened apps show up in the bar.

~/dotfiles/dotfiles/mac/aerospace/update-ws-cache.sh

FOCUSED_GROUP=$(sed -n '1p' /tmp/aerospace-ws-cache)

# Trigger all workspace events so sketchybar redraws visibility
for i in 1 2 3 4 5 6 7 8 9; do
    /opt/homebrew/bin/sketchybar --trigger "aerospace_workspace_change_$i" "FOCUSED_WORKSPACE=$FOCUSED_GROUP" 2>/dev/null &
done
wait
