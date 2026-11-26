#!/bin/bash
# Pause workspace title refreshes (ws_title_poll and the herdr listener) while the
# screen is locked, then refresh once on unlock.

LOCK_FLAG="/tmp/sketchybar-screen-locked"

case "$SENDER" in
    screen_locked) touch "$LOCK_FLAG" ;;
    screen_unlocked)
        rm -f "$LOCK_FLAG"
        "$(dirname "$0")/ws_title_poll.sh"
        ;;
esac
