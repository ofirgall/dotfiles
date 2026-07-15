#!/bin/bash

# Move the window from an on-window-detected event to the workspace under the
# mouse without changing focus.

case "${AEROSPACE_WINDOW_ID:-}" in
    ''|*[!0-9]*)
        echo "move-window-to-cursor-monitor: invalid window ID" >&2
        exit 1
        ;;
esac

TARGET_WORKSPACE=$(
    aerospace list-workspaces --monitor mouse --visible --format '%{workspace}' \
        2>/dev/null
) || {
    echo "move-window-to-cursor-monitor: cannot determine cursor workspace" >&2
    exit 1
}

case "$TARGET_WORKSPACE" in
    ''|*$'\n'*)
        echo "move-window-to-cursor-monitor: expected one cursor workspace" >&2
        exit 1
        ;;
esac

exec aerospace move-node-to-workspace \
    --focus-follows-window \
    --window-id "$AEROSPACE_WINDOW_ID" -- "$TARGET_WORKSPACE"
