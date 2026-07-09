#!/bin/bash

COUNT=$(aerospace list-windows --workspace focused 2>/dev/null | wc -l | tr -d ' ')

if [ "$COUNT" -gt 0 ] 2>/dev/null; then
    LAYOUT=$(aerospace list-workspaces --focused --format '%{workspace-root-container-layout}' 2>/dev/null)

    case "$LAYOUT" in
        *accordion*) COLOR=0xff94e2d5 ;;  # teal — maximized
        *)           COLOR=0xffcba6f7 ;;  # mauve — tiled
    esac

    sketchybar --set "$NAME" label="${COUNT}" drawing=on icon.color="$COLOR" label.color="$COLOR"
else
    sketchybar --set "$NAME" drawing=off
fi
