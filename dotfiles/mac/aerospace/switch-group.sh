#!/bin/bash
# Switch all monitors to workspace group N.
# Each monitor shows its corresponding sub-workspace: N, Nb, Nc (by sequence number).

GROUP="$1"
[ -z "$GROUP" ] && exit 1

SUFFIXES=("" "b" "c")
NUM_MONITORS=$(aerospace list-monitors 2>/dev/null | wc -l | tr -d ' ')
FOCUSED_MON=$(aerospace list-monitors --focused --format '%{monitor-id}' 2>/dev/null)

# Determine current group from focused workspace
CURRENT_WS=$(aerospace list-workspaces --focused 2>/dev/null)
CURRENT_GROUP="${CURRENT_WS%%[bc]}"

# No-op if already on this group
[ "$CURRENT_GROUP" = "$GROUP" ] && exit 0

# Save previous group for back-and-forth
echo "$CURRENT_GROUP" > /tmp/aerospace-prev-group

# Set flag so on-workspace-change.sh skips sticky-move (we handle it here)
touch /tmp/aerospace-switching-group

# Collect current visible workspace per monitor, then switch + move sticky windows
STICKY_FILE="/tmp/aerospace-sticky-windows"
for i in $(seq 0 $((NUM_MONITORS - 1))); do
    MON_SEQ=$((i + 1))
    OLD_WS="${CURRENT_GROUP}${SUFFIXES[$i]}"
    NEW_WS="${GROUP}${SUFFIXES[$i]}"

    aerospace workspace "$NEW_WS" 2>/dev/null

    # Move sticky windows from old to new workspace on this monitor
    if [ -f "$STICKY_FILE" ]; then
        while IFS= read -r wid; do
            [ -z "$wid" ] && continue
            WIN_WS=$(aerospace list-windows --all --format '%{window-id} %{workspace}' 2>/dev/null | awk -v id="$wid" '$1 == id {print $2}')
            if [ "$WIN_WS" = "$OLD_WS" ]; then
                aerospace move-node-to-workspace "$NEW_WS" --window-id "$wid" 2>/dev/null
            fi
        done < "$STICKY_FILE"
    fi
done

rm -f /tmp/aerospace-switching-group

# Return focus to the original monitor
aerospace focus-monitor "$FOCUSED_MON" 2>/dev/null
