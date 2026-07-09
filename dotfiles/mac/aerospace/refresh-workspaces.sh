#!/bin/bash
# Refresh sketchybar after a window moves between workspaces.
# run.py updates sentinel + labels, then aerospace.sh updates highlights.
# Usage: refresh-workspaces.sh <target_workspace_id>

TARGET="$1"
FOCUSED=$(/opt/homebrew/bin/aerospace list-workspaces --focused)

/opt/homebrew/bin/python3.14 /Users/ofirgal/agents-status/statusbar/run.py

/opt/homebrew/bin/sketchybar \
    --trigger "aerospace_workspace_change_$TARGET" "FOCUSED_WORKSPACE=$FOCUSED" \
    --trigger "aerospace_workspace_change_$FOCUSED" "FOCUSED_WORKSPACE=$FOCUSED"
