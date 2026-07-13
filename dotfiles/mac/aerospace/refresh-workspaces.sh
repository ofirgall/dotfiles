#!/bin/bash
# Refresh sketchybar after a window moves between workspaces.
# run.py updates sentinel + names, then aerospace.sh reads fresh sentinel for highlights.
# Usage: refresh-workspaces.sh <target_group_number>

TARGET="$1"
FOCUSED_RAW=$(/opt/homebrew/bin/aerospace list-workspaces --focused)
FOCUSED_GROUP="${FOCUSED_RAW%%[bc]}"

/opt/homebrew/bin/python3.14 /Users/ofirgal/agents-status/statusbar/run.py

/opt/homebrew/bin/sketchybar \
    --trigger "aerospace_workspace_change_$TARGET" "FOCUSED_WORKSPACE=$FOCUSED_RAW" \
    --trigger "aerospace_workspace_change_$FOCUSED_GROUP" "FOCUSED_WORKSPACE=$FOCUSED_RAW"
