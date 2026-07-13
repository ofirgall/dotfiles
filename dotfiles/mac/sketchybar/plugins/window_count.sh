#!/bin/bash

COUNT=$(aerospace list-windows --workspace focused 2>/dev/null | wc -l | tr -d ' ')
WINDOW_TITLE=$(aerospace list-windows --focused --format '%{window-title}' 2>/dev/null)

# Determine item name pair based on which item triggered us
case "$NAME" in
    *_ext) COUNT_ITEM="window_count_ext"; NAME_ITEM="window_name_ext" ;;
    *)     COUNT_ITEM="window_count";     NAME_ITEM="window_name" ;;
esac

if [ "$COUNT" -gt 0 ] 2>/dev/null; then
    LAYOUT=$(aerospace list-workspaces --focused --format '%{workspace-root-container-layout}' 2>/dev/null)

    case "$LAYOUT" in
        *accordion*) COLOR=0xff94e2d5 ;;  # teal — maximized
        *)           COLOR=0xffcba6f7 ;;  # mauve — tiled
    esac

    sketchybar --set "$COUNT_ITEM" label="${COUNT}" drawing=on icon.color="$COLOR" label.color="$COLOR" \
               --set "$NAME_ITEM" label="${WINDOW_TITLE}" drawing=on label.color="$COLOR"
else
    sketchybar --set "$COUNT_ITEM" drawing=off \
               --set "$NAME_ITEM" drawing=off
fi
