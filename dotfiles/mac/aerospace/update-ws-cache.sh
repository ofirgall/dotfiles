#!/bin/bash
# Pre-compute workspace state for all groups with minimal aerospace calls.
# Writes /tmp/aerospace-ws-cache which aerospace.sh reads.
# Format: line 1 = focused group, lines 2+ = "GROUP HAS_WINDOWS WIN_COUNT"

CACHE="/tmp/aerospace-ws-cache"

FOCUSED_RAW=$(aerospace list-workspaces --focused 2>/dev/null)
FOCUSED_GROUP="${FOCUSED_RAW%%[bc]}"

# Single aerospace call, count windows per group in one awk pass
aerospace list-windows --all --format '%{workspace}' 2>/dev/null | awk -v fg="$FOCUSED_GROUP" '
BEGIN { for (i=1; i<=9; i++) count[i]=0 }
{
    ws = $1
    gsub(/[bc]$/, "", ws)
    if (ws+0 >= 1 && ws+0 <= 9) count[ws+0]++
}
END {
    print fg
    for (i=1; i<=9; i++) {
        has = (count[i] > 0) ? 1 : 0
        print i, has, count[i]
    }
}' > "$CACHE"
