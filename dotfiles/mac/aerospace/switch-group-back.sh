#!/bin/bash
# Switch all monitors back to the previous workspace group (back-and-forth).

PREV_GROUP_FILE="/tmp/aerospace-prev-group"
[ -f "$PREV_GROUP_FILE" ] || exit 0

PREV_GROUP=$(cat "$PREV_GROUP_FILE")
[ -z "$PREV_GROUP" ] && exit 0

exec ~/dotfiles/dotfiles/mac/aerospace/switch-group.sh "$PREV_GROUP"
