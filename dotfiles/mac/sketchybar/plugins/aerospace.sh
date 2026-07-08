#!/bin/bash

FOCUSED=$(aerospace list-workspaces --focused 2>/dev/null)
NON_EMPTY=$(aerospace list-workspaces --monitor all --empty no 2>/dev/null)

IS_FOCUSED=$( [ "$1" = "$FOCUSED" ] && echo "true" || echo "false" )
HAS_WINDOWS=$(echo "$NON_EMPTY" | grep -q "^$1$" && echo "true" || echo "false")

if [ "$IS_FOCUSED" = "true" ]; then
    sketchybar --set "$NAME" background.drawing=on icon.color=0xff1e1e2e drawing=on
elif [ "$HAS_WINDOWS" = "true" ]; then
    sketchybar --set "$NAME" background.drawing=off icon.color=0xffcad3f5 drawing=on
else
    sketchybar --set "$NAME" drawing=off
fi
