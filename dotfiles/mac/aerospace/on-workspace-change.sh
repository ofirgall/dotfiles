#!/bin/bash
# Fired by exec-on-workspace-change. Handles:
# 1. Sticky window movement (skipped during group switches — handled by switch-group.sh)
# 2. Pre-compute workspace cache (so sketchybar plugin is fast)
# 3. SketchyBar group event triggering
#
# During group switches (flag file exists), everything is skipped —
# switch-group.sh does a single consolidated update at the end.

[ -f /tmp/aerospace-switching-group ] && exit 0

~/dotfiles/dotfiles/mac/aerospace/sticky-move.sh

# Update cache before triggering sketchybar (2 aerospace calls for all 9 groups)
~/dotfiles/dotfiles/mac/aerospace/update-ws-cache.sh

FOCUSED="$AEROSPACE_FOCUSED_WORKSPACE"
PREV="$AEROSPACE_PREV_WORKSPACE"

FOCUSED_GROUP="${FOCUSED%%[bc]}"
PREV_GROUP="${PREV%%[bc]}"

/opt/homebrew/bin/sketchybar \
    --trigger "aerospace_workspace_change_${PREV_GROUP}" "FOCUSED_WORKSPACE=$FOCUSED" \
    --trigger "aerospace_workspace_change_${FOCUSED_GROUP}" "FOCUSED_WORKSPACE=$FOCUSED" 2>/dev/null
