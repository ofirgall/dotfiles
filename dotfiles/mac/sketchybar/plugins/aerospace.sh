#!/bin/bash

if [ "$SENDER" = "aerospace_workspace_change_$1" ]; then
    FOCUSED="$FOCUSED_WORKSPACE"
else
    FOCUSED=$(aerospace list-workspaces --focused 2>/dev/null)
fi

if [ "$1" = "$FOCUSED" ]; then
    sketchybar --set "$NAME" background.drawing=on icon.color=0xff1e1e2e
else
    sketchybar --set "$NAME" background.drawing=off icon.color=0xffcad3f5
fi
