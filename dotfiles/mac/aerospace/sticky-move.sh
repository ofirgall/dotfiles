#!/bin/bash

STICKY_FILE="/tmp/aerospace-sticky-windows"
[ -f "$STICKY_FILE" ] || exit 0

TARGET_WS="$AEROSPACE_FOCUSED_WORKSPACE"
PREV_WS="$AEROSPACE_PREV_WORKSPACE"
[ -z "$TARGET_WS" ] || [ -z "$PREV_WS" ] && exit 0
[ "$TARGET_WS" = "$PREV_WS" ] && exit 0

# Only proceed if prev and target are on the same monitor
TARGET_MON=$(aerospace list-workspaces --monitor all --format '%{workspace} %{monitor-id}' 2>/dev/null | awk -v ws="$TARGET_WS" '$1 == ws {print $2}')
PREV_MON=$(aerospace list-workspaces --monitor all --format '%{workspace} %{monitor-id}' 2>/dev/null | awk -v ws="$PREV_WS" '$1 == ws {print $2}')
[ "$TARGET_MON" != "$PREV_MON" ] && exit 0

while IFS= read -r wid; do
    [ -z "$wid" ] && continue
    WIN_WS=$(aerospace list-windows --all --format '%{window-id} %{workspace}' 2>/dev/null | awk -v id="$wid" '$1 == id {print $2}')
    if [ "$WIN_WS" = "$PREV_WS" ]; then
        aerospace move-node-to-workspace "$TARGET_WS" --window-id "$wid" 2>/dev/null
    fi
done < "$STICKY_FILE"
