#!/bin/bash
# Refresh sketchybar after a window moves between workspaces.
# Usage: refresh-workspaces.sh <target_group_number>

TARGET="$1"

~/dotfiles/dotfiles/mac/aerospace/update-ws-cache.sh
FOCUSED_GROUP=$(sed -n '1p' /tmp/aerospace-ws-cache)

/opt/homebrew/bin/sketchybar \
    --trigger "aerospace_workspace_change_$TARGET" "FOCUSED_WORKSPACE=$FOCUSED_GROUP" \
    --trigger "aerospace_workspace_change_$FOCUSED_GROUP" "FOCUSED_WORKSPACE=$FOCUSED_GROUP"
