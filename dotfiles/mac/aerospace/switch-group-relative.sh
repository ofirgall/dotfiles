#!/bin/bash
# Switch all monitors to prev/next workspace group.
# Usage: switch-group-relative.sh prev|next

DIRECTION="$1"
CURRENT_WS=$(aerospace list-workspaces --focused 2>/dev/null)
CURRENT_GROUP="${CURRENT_WS%%[bc]}"

if [ "$DIRECTION" = "prev" ]; then
    TARGET=$(( CURRENT_GROUP - 1 ))
    [ "$TARGET" -lt 1 ] && TARGET=9
else
    TARGET=$(( CURRENT_GROUP + 1 ))
    [ "$TARGET" -gt 9 ] && TARGET=1
fi

exec ~/dotfiles/dotfiles/mac/aerospace/switch-group.sh "$TARGET"
