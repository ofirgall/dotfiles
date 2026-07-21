#!/bin/bash
# Fired by exec-on-workspace-change. Handles:
# 1. Sticky window movement (skipped during group switches — handled by switch-group.sh)
# 2. Pre-compute workspace cache (so sketchybar plugin is fast)
# 3. SketchyBar group event triggering
#
# During group switches (flag file exists), everything is skipped —
# switch-group.sh does a single consolidated update at the end.

LOG="/tmp/aerospace-close.log"
DBG() { [ -f /tmp/aerospace-debug-enabled ] && echo "$*" >> "$LOG"; }

[ -f /tmp/aerospace-switching-group ] && exit 0

# Revert unwanted workspace switch caused by macOS focus-stealing after window close
if [ -f /tmp/aerospace-close-revert ]; then
    read -r DESIRED_GROUP DESIRED_MON < /tmp/aerospace-close-revert
    DBG "on-ws-change: revert file found, GROUP=$DESIRED_GROUP MON=$DESIRED_MON FOCUSED=$AEROSPACE_FOCUSED_WORKSPACE PREV=$AEROSPACE_PREV_WORKSPACE $(date +%H:%M:%S.%N)"
    rm -f /tmp/aerospace-close-revert
    FOCUSED_GROUP="${AEROSPACE_FOCUSED_WORKSPACE%%[bc]}"
    if [ "$FOCUSED_GROUP" != "$DESIRED_GROUP" ]; then
        DBG "on-ws-change: reverting all monitors to group $DESIRED_GROUP"
        touch /tmp/aerospace-switching-group
        SUFFIXES=("" "b" "c")
        NUM_MONITORS=$(aerospace list-monitors --format '%{monitor-id}' 2>/dev/null | wc -l | tr -d ' ')
        EVAL_CMD=""
        for i in $(seq 0 $((NUM_MONITORS - 1))); do
            EVAL_CMD="${EVAL_CMD}workspace ${DESIRED_GROUP}${SUFFIXES[$i]}; "
        done
        EVAL_CMD="${EVAL_CMD}focus-monitor ${DESIRED_MON}"
        aerospace eval "$EVAL_CMD" 2>/dev/null
        rm -f /tmp/aerospace-switching-group
        DBG "on-ws-change: revert done, final=$(aerospace list-workspaces --focused 2>/dev/null)"
    else
        DBG "on-ws-change: already on desired group, no revert needed"
    fi
    ~/dotfiles/dotfiles/mac/aerospace/on-window-detected.sh
    exit 0
fi

~/dotfiles/dotfiles/mac/aerospace/sticky-move.sh

# Update cache before triggering sketchybar (2 aerospace calls for all 10 groups)
~/agents-status/statusbar/sketchybar/update-ws-cache.sh

FOCUSED="$AEROSPACE_FOCUSED_WORKSPACE"
PREV="$AEROSPACE_PREV_WORKSPACE"

FOCUSED_GROUP="${FOCUSED%%[bc]}"
PREV_GROUP="${PREV%%[bc]}"

/opt/homebrew/bin/sketchybar \
    --trigger "aerospace_workspace_change_${PREV_GROUP}" "FOCUSED_WORKSPACE=$FOCUSED_GROUP" \
    --trigger "aerospace_workspace_change_${FOCUSED_GROUP}" "FOCUSED_WORKSPACE=$FOCUSED_GROUP" 2>/dev/null
