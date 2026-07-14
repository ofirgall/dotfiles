#!/bin/bash

COUNT=$(aerospace list-windows --workspace focused 2>/dev/null | wc -l | tr -d ' ')
WINDOW_TITLE=$(aerospace list-windows --focused --format '%{window-title}' 2>/dev/null)

if [ "$COUNT" -gt 0 ] 2>/dev/null; then
    LAYOUT=$(aerospace list-workspaces --focused --format '%{workspace-root-container-layout}' 2>/dev/null)

    case "$LAYOUT" in
        *accordion*) COLOR=0xff94e2d5 ;;  # teal — maximized
        *)           COLOR=0xffcba6f7 ;;  # mauve — tiled
    esac

    sketchybar --set window_count label="${COUNT}" drawing=on icon.color="$COLOR" label.color="$COLOR" \
               --set window_name label="${WINDOW_TITLE}" drawing=on label.color="$COLOR"
else
    sketchybar --set window_count drawing=off \
               --set window_name drawing=off
fi
