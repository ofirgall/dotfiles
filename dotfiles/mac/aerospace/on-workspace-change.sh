#!/bin/bash
# Fired by exec-on-workspace-change. Handles:
# 1. Sticky window movement (skipped during group switches — handled by switch-group.sh)
# 2. SketchyBar group event triggering (translates sub-workspace names to group numbers)

if [ ! -f /tmp/aerospace-switching-group ]; then
    ~/dotfiles/dotfiles/mac/aerospace/sticky-move.sh
fi

FOCUSED="$AEROSPACE_FOCUSED_WORKSPACE"
PREV="$AEROSPACE_PREV_WORKSPACE"

# Strip suffix to get group number
FOCUSED_GROUP="${FOCUSED%%[bc]}"
PREV_GROUP="${PREV%%[bc]}"

/opt/homebrew/bin/sketchybar \
    --trigger "aerospace_workspace_change_${PREV_GROUP}" "FOCUSED_WORKSPACE=$FOCUSED" \
    --trigger "aerospace_workspace_change_${FOCUSED_GROUP}" "FOCUSED_WORKSPACE=$FOCUSED" 2>/dev/null
