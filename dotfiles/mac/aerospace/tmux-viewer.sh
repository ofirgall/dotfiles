#!/usr/bin/env bash

TITLE=$(aerospace list-windows --focused --format '%{window-title}')
SUFFIX=" - TMUX"

if [[ "$TITLE" == *"$SUFFIX" ]]; then
    SESSION_NAME="${TITLE%$SUFFIX}"
    echo "$SESSION_NAME" > /tmp/tmux-viewer-pending
    osascript -e 'tell application "Ghostty" to new window'
else
    osascript -e 'display notification "Active window is not a TMUX session" with title "TmuxViewer"'
fi
