#!/bin/bash
# Swap focused window with the neighbor in the given direction.
# Works within a workspace (native move) and across monitors.
#
# Usage: swap-window.sh <left|down|up|right>

DIR="$1"
[ -z "$DIR" ] && exit 1

SRC_ID=$(aerospace list-windows --focused --format '%{window-id}' 2>/dev/null)
SRC_WS=$(aerospace list-windows --focused --format '%{workspace}' 2>/dev/null)
[ -z "$SRC_ID" ] && exit 1

# Try native move first (within workspace). If it succeeds, we're done.
if aerospace move --boundaries workspace --boundaries-action fail "$DIR" 2>/dev/null; then
    exit 0
fi

# Native move failed (at workspace edge). Try cross-monitor swap.
# Focus the neighbor across the monitor boundary.
if ! aerospace focus --boundaries all-monitors-outer-frame "$DIR" 2>/dev/null; then
    exit 1
fi

DST_ID=$(aerospace list-windows --focused --format '%{window-id}' 2>/dev/null)
DST_WS=$(aerospace list-windows --focused --format '%{workspace}' 2>/dev/null)

# If focus didn't actually change, nothing to swap with.
if [ "$SRC_ID" = "$DST_ID" ]; then
    exit 0
fi

# Swap: move each window to the other's workspace.
aerospace move-node-to-workspace --window-id "$SRC_ID" "$DST_WS" 2>/dev/null
aerospace move-node-to-workspace --window-id "$DST_ID" "$SRC_WS" 2>/dev/null

# Focus back on the original window.
aerospace focus --window-id "$SRC_ID" 2>/dev/null
