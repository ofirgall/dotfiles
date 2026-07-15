#!/bin/bash
# Switch all monitors to workspace group N.
# Each monitor shows its corresponding sub-workspace: N, Nb, Nc (by sequence number).
# Uses `aerospace eval` to batch all switches in a single atomic server transaction,
# preventing macOS focus events from interfering between switches.

GROUP="$1"
[ -z "$GROUP" ] && exit 1

SUFFIXES=("" "b" "c")

# Serialize: only one switch-group at a time
LOCKDIR="/tmp/aerospace-switch-group.lock"
if ! mkdir "$LOCKDIR" 2>/dev/null; then
    exit 0
fi
trap 'rm -rf "$LOCKDIR"' EXIT

# Read current group from cache (avoids an aerospace call)
CACHE="/tmp/aerospace-ws-cache"
if [ -f "$CACHE" ]; then
    CURRENT_GROUP=$(sed -n '1p' "$CACHE")
else
    CURRENT_WS=$(aerospace list-workspaces --focused 2>/dev/null)
    CURRENT_GROUP="${CURRENT_WS%%[bc]}"
fi

# No-op if already on this group
[ "$CURRENT_GROUP" = "$GROUP" ] && exit 0

FOCUSED_MON=$(aerospace list-monitors --focused --format '%{monitor-id}' 2>/dev/null)
NUM_MONITORS=$(aerospace list-monitors --format '%{monitor-id}' 2>/dev/null | wc -l | tr -d ' ')

# Save previous group for back-and-forth
echo "$CURRENT_GROUP" > /tmp/aerospace-prev-group

# Set flag so on-workspace-change.sh hooks are no-ops
touch /tmp/aerospace-switching-group

# Update cache + trigger sketchybar IMMEDIATELY (before workspace switches)
FOCUSED_WS="${GROUP}${SUFFIXES[$((FOCUSED_MON-1))]}"
TMP_CACHE="${CACHE}.tmp.$$"
awk -v g="$GROUP" 'NR==1{print g; next}{print}' "$CACHE" > "$TMP_CACHE" && mv "$TMP_CACHE" "$CACHE"
/opt/homebrew/bin/sketchybar \
    --trigger "aerospace_workspace_change_${CURRENT_GROUP}" "FOCUSED_WORKSPACE=$FOCUSED_WS" \
    --trigger "aerospace_workspace_change_${GROUP}" "FOCUSED_WORKSPACE=$FOCUSED_WS" 2>/dev/null &

# Build a single eval expression for all workspace switches + sticky moves
EVAL_CMD=""

# Pre-fetch sticky window locations ONCE
STICKY_FILE="/tmp/aerospace-sticky-windows"
ALL_WIN_WS=""
if [ -s "$STICKY_FILE" ]; then
    ALL_WIN_WS=$(aerospace list-windows --all --format '%{window-id} %{workspace}' 2>/dev/null)
fi

for i in $(seq 0 $((NUM_MONITORS - 1))); do
    OLD_WS="${CURRENT_GROUP}${SUFFIXES[$i]}"
    NEW_WS="${GROUP}${SUFFIXES[$i]}"

    # Append sticky window moves to the eval batch
    if [ -n "$ALL_WIN_WS" ]; then
        while IFS= read -r wid; do
            [ -z "$wid" ] && continue
            WIN_WS=$(echo "$ALL_WIN_WS" | awk -v id="$wid" '$1 == id {print $2}')
            if [ "$WIN_WS" = "$OLD_WS" ]; then
                EVAL_CMD="${EVAL_CMD}move-node-to-workspace ${NEW_WS} --window-id ${wid}; "
            fi
        done < "$STICKY_FILE"
    fi

    EVAL_CMD="${EVAL_CMD}workspace ${NEW_WS}; "
done

# Return focus to the original monitor (included in the batch)
EVAL_CMD="${EVAL_CMD}focus-monitor ${FOCUSED_MON}"

# Single atomic IPC call — all commands processed server-side without interleaving
aerospace eval "$EVAL_CMD" 2>/dev/null

# Remove flag synchronously (all switches are done)
rm -f /tmp/aerospace-switching-group
