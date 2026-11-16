#!/bin/bash
# display_change fires several times in a burst on unlock or a resolution change, often
# while the geometry is still settling. Wait for the burst to end, then re-detect and
# reload once, and only if the displays actually changed.

LOCKFILE="/tmp/sketchybar-display-change.pid"

echo $$ > "$LOCKFILE"
sleep 1
[ "$(cat "$LOCKFILE" 2>/dev/null)" = "$$" ] || exit 0

"$(dirname "$0")/detect_displays.sh" && sketchybar --reload
