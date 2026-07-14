#!/bin/bash
# Move focused window to workspace group N on the SAME monitor.
# Determines which sub-workspace (N, Nb, Nc) based on current monitor.

GROUP="$1"
[ -z "$GROUP" ] && exit 1

SUFFIXES=("" "b" "c")
FOCUSED_MON=$(aerospace list-monitors --focused --format '%{monitor-id}' 2>/dev/null)
SUFFIX_IDX=$((FOCUSED_MON - 1))
TARGET_WS="${GROUP}${SUFFIXES[$SUFFIX_IDX]}"

aerospace move-node-to-workspace "$TARGET_WS" 2>/dev/null

# Refresh cache + sketchybar
~/dotfiles/dotfiles/mac/aerospace/update-ws-cache.sh
FOCUSED_GROUP=$(sed -n '1p' /tmp/aerospace-ws-cache)

/opt/homebrew/bin/python3.14 /Users/ofirgal/agents-status/statusbar/run.py 2>/dev/null &
/opt/homebrew/bin/sketchybar \
    --trigger "aerospace_workspace_change_${FOCUSED_GROUP}" "FOCUSED_WORKSPACE=$FOCUSED_GROUP" \
    --trigger "aerospace_workspace_change_${GROUP}" "FOCUSED_WORKSPACE=$FOCUSED_GROUP" 2>/dev/null
