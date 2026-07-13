#!/bin/bash
# Switch all monitors to workspace group N.
# Each monitor shows its corresponding sub-workspace: N, Nb, Nc (by sequence number).

GROUP="$1"
[ -z "$GROUP" ] && exit 1

SUFFIXES=("" "b" "c")

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
NUM_MONITORS=$(aerospace list-monitors 2>/dev/null | wc -l | tr -d ' ')

# Save previous group for back-and-forth
echo "$CURRENT_GROUP" > /tmp/aerospace-prev-group

# Set flag so on-workspace-change.sh hooks are no-ops
touch /tmp/aerospace-switching-group

# Update cache + trigger sketchybar IMMEDIATELY (before workspace switches)
FOCUSED_WS="${GROUP}${SUFFIXES[$((FOCUSED_MON-1))]}"
sed -i '' "1s/.*/$GROUP/" /tmp/aerospace-ws-cache 2>/dev/null
/opt/homebrew/bin/sketchybar \
    --trigger "aerospace_workspace_change_${CURRENT_GROUP}" "FOCUSED_WORKSPACE=$FOCUSED_WS" \
    --trigger "aerospace_workspace_change_${GROUP}" "FOCUSED_WORKSPACE=$FOCUSED_WS" 2>/dev/null &

# Pre-fetch sticky window locations ONCE (avoids N*M aerospace calls in the loop)
STICKY_FILE="/tmp/aerospace-sticky-windows"
ALL_WIN_WS=""
if [ -s "$STICKY_FILE" ]; then
    ALL_WIN_WS=$(aerospace list-windows --all --format '%{window-id} %{workspace}' 2>/dev/null)
fi

# Switch all monitors to the target group
for i in $(seq 0 $((NUM_MONITORS - 1))); do
    OLD_WS="${CURRENT_GROUP}${SUFFIXES[$i]}"
    NEW_WS="${GROUP}${SUFFIXES[$i]}"

    # Move sticky windows BEFORE switching (shorter flicker — window is already
    # on target workspace when it becomes visible)
    if [ -n "$ALL_WIN_WS" ]; then
        while IFS= read -r wid; do
            [ -z "$wid" ] && continue
            WIN_WS=$(echo "$ALL_WIN_WS" | awk -v id="$wid" '$1 == id {print $2}')
            if [ "$WIN_WS" = "$OLD_WS" ]; then
                aerospace move-node-to-workspace "$NEW_WS" --window-id "$wid" 2>/dev/null
            fi
        done < "$STICKY_FILE"
    fi

    aerospace workspace "$NEW_WS" 2>/dev/null
done

# Return focus to the original monitor
aerospace focus-monitor "$FOCUSED_MON" 2>/dev/null

# Delayed flag removal
(sleep 0.3 && rm -f /tmp/aerospace-switching-group) &
