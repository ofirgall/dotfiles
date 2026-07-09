#!/bin/bash

COUNT=$(aerospace list-windows --workspace focused 2>/dev/null | wc -l | tr -d ' ')

if [ "$COUNT" -gt 0 ] 2>/dev/null; then
    sketchybar --set "$NAME" label="${COUNT}" drawing=on
else
    sketchybar --set "$NAME" drawing=off
fi
