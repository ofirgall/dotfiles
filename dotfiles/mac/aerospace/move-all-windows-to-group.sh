#!/bin/bash
# Move ALL windows from all workspaces to a target group, then switch to it.

TARGET_GROUP="${1:-10}"

# Get current monitor to determine target sub-workspace
MON=$(aerospace list-monitors --focused --format '%{monitor-id}' 2>/dev/null)
case "$MON" in
    1) TARGET_WS="$TARGET_GROUP" ;;
    2) TARGET_WS="${TARGET_GROUP}b" ;;
    3) TARGET_WS="${TARGET_GROUP}c" ;;
    *) TARGET_WS="$TARGET_GROUP" ;;
esac

# Collect all tiling window IDs across all workspaces
ALL_WINDOWS=$(aerospace list-windows --all --format '%{window-id}' 2>/dev/null)

[ -z "$ALL_WINDOWS" ] && exit 0

# Build a single eval batch
EVAL_CMD=""
while IFS= read -r wid; do
    [ -z "$wid" ] && continue
    EVAL_CMD="${EVAL_CMD}move-node-to-workspace ${TARGET_WS} --window-id ${wid}; "
done <<< "$ALL_WINDOWS"

[ -n "$EVAL_CMD" ] && aerospace eval "$EVAL_CMD" 2>/dev/null

# Invalidate cache and switch to the target group
rm -f /tmp/aerospace-ws-cache
~/dotfiles/dotfiles/mac/aerospace/switch-group.sh "$TARGET_GROUP"

# Full refresh since windows moved from many workspaces
~/dotfiles/dotfiles/mac/aerospace/on-window-detected.sh &
