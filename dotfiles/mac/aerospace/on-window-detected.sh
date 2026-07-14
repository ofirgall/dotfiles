#!/bin/bash
# Refresh workspace cache + sketchybar when a new window appears.
# This ensures workspaces with newly opened apps show up in the bar.

~/dotfiles/dotfiles/mac/aerospace/update-ws-cache.sh

FOCUSED_GROUP=$(sed -n '1p' /tmp/aerospace-ws-cache)

/opt/homebrew/bin/sketchybar \
    --trigger aerospace_workspace_change_1 "FOCUSED_WORKSPACE=$FOCUSED_GROUP" \
    --trigger aerospace_workspace_change_2 "FOCUSED_WORKSPACE=$FOCUSED_GROUP" \
    --trigger aerospace_workspace_change_3 "FOCUSED_WORKSPACE=$FOCUSED_GROUP" \
    --trigger aerospace_workspace_change_4 "FOCUSED_WORKSPACE=$FOCUSED_GROUP" \
    --trigger aerospace_workspace_change_5 "FOCUSED_WORKSPACE=$FOCUSED_GROUP" \
    --trigger aerospace_workspace_change_6 "FOCUSED_WORKSPACE=$FOCUSED_GROUP" \
    --trigger aerospace_workspace_change_7 "FOCUSED_WORKSPACE=$FOCUSED_GROUP" \
    --trigger aerospace_workspace_change_8 "FOCUSED_WORKSPACE=$FOCUSED_GROUP" \
    --trigger aerospace_workspace_change_9 "FOCUSED_WORKSPACE=$FOCUSED_GROUP" 2>/dev/null
