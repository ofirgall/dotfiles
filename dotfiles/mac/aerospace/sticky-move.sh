#!/bin/bash

STICKY_FILE="/tmp/aerospace-sticky-windows"
[ -s "$STICKY_FILE" ] || exit 0

TARGET_WS="$AEROSPACE_FOCUSED_WORKSPACE"
PREV_WS="$AEROSPACE_PREV_WORKSPACE"
[ -z "$TARGET_WS" ] || [ -z "$PREV_WS" ] && exit 0
[ "$TARGET_WS" = "$PREV_WS" ] && exit 0

# Single call to check if both workspaces are on the same monitor
MON_MAP=$(aerospace list-workspaces --monitor all --format '%{workspace} %{monitor-id}' 2>/dev/null)
TARGET_MON=$(echo "$MON_MAP" | awk -v ws="$TARGET_WS" '$1 == ws {print $2}')
PREV_MON=$(echo "$MON_MAP" | awk -v ws="$PREV_WS" '$1 == ws {print $2}')
[ "$TARGET_MON" != "$PREV_MON" ] && exit 0

# Single call to get all window locations
ALL_WIN_WS=$(aerospace list-windows --all --format '%{window-id} %{workspace}' 2>/dev/null)

# Build a single eval batch for all sticky moves
EVAL_CMD=""
while IFS= read -r wid; do
    [ -z "$wid" ] && continue
    WIN_WS=$(echo "$ALL_WIN_WS" | awk -v id="$wid" '$1 == id {print $2}')
    if [ "$WIN_WS" = "$PREV_WS" ]; then
        EVAL_CMD="${EVAL_CMD}move-node-to-workspace ${TARGET_WS} --window-id ${wid}; "
    fi
done < "$STICKY_FILE"

[ -n "$EVAL_CMD" ] && aerospace eval "$EVAL_CMD" 2>/dev/null
