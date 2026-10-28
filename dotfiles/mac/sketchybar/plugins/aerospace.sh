#!/bin/bash
# Render one workspace item: number as icon, app icons as label.
# Reads /tmp/aerospace-ws-cache written by aerospace/update-ws-cache.sh.
# Usage: aerospace.sh <group>

FOCUSED_BG=0xffcba6f7
FOCUSED_TEXT=0xff1e1e1e
UNFOCUSED_BG=0xff23243e
UNFOCUSED_TEXT=0xffa287c5

CACHE="/tmp/aerospace-ws-cache"
if [ -f "$CACHE" ]; then
    FOCUSED_GROUP=$(sed -n '1p' "$CACHE")
    read -r _ HAS_WINDOWS _ APP_ICONS <<< "$(grep "^$1 " "$CACHE")"
else
    FOCUSED_GROUP=$(aerospace list-workspaces --focused 2>/dev/null)
    FOCUSED_GROUP="${FOCUSED_GROUP%%[bc]}"
fi

if [ "$1" = "$FOCUSED_GROUP" ]; then
    BG=$FOCUSED_BG; TEXT=$FOCUSED_TEXT
elif [ "$HAS_WINDOWS" = "1" ]; then
    BG=$UNFOCUSED_BG; TEXT=$UNFOCUSED_TEXT
else
    sketchybar --set "$NAME" drawing=off
    exit 0
fi

if [ -n "$APP_ICONS" ]; then
    LABEL_PROPS=("label=$APP_ICONS" label.drawing=on)
else
    LABEL_PROPS=(label.drawing=off)
fi

sketchybar --set "$NAME" drawing=on "${LABEL_PROPS[@]}" \
    background.color="$BG" background.drawing=on \
    icon.color="$TEXT" label.color="$TEXT"
