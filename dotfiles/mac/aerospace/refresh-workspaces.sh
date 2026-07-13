#!/bin/bash
# Refresh sketchybar after a window moves between workspaces.
# run.py updates sentinel + names, then aerospace.sh reads fresh sentinel for highlights.
# Usage: refresh-workspaces.sh <target_group_number>

TARGET="$1"

~/dotfiles/dotfiles/mac/aerospace/update-ws-cache.sh
FOCUSED_GROUP=$(sed -n '1p' /tmp/aerospace-ws-cache)

/opt/homebrew/bin/python3.14 /Users/ofirgal/agents-status/statusbar/run.py

/opt/homebrew/bin/sketchybar \
    --trigger "aerospace_workspace_change_$TARGET" "FOCUSED_WORKSPACE=$FOCUSED_GROUP" \
    --trigger "aerospace_workspace_change_$FOCUSED_GROUP" "FOCUSED_WORKSPACE=$FOCUSED_GROUP"
