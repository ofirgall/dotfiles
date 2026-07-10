#!/usr/bin/env bash

TITLE=$(aerospace list-windows --focused --format '%{window-title}')
SUFFIX=" - TMUX"

if [[ "$TITLE" == *"$SUFFIX" ]]; then
    SESSION_NAME="${TITLE%$SUFFIX}"
    open -na Ghostty.app --args --command="/bin/zsh -c 'export VIEW_TMUX_SESSION=\"$SESSION_NAME\"; exec zsh -i'"
else
    osascript -e 'display notification "Active window is not a TMUX session" with title "TmuxViewer"'
fi
