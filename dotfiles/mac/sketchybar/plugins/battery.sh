#!/bin/bash

PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ -n "$CHARGING" ]; then
    ICON="󰂄"
    COLOR=0xffa6e3a1  # green
elif [ "$PERCENTAGE" -gt 80 ]; then
    ICON="󰁹"
    COLOR=0xffa6e3a1  # green
elif [ "$PERCENTAGE" -gt 60 ]; then
    ICON="󰂀"
    COLOR=0xffa6e3a1  # green
elif [ "$PERCENTAGE" -gt 40 ]; then
    ICON="󰁾"
    COLOR=0xffa6e3a1  # green
elif [ "$PERCENTAGE" -gt 20 ]; then
    ICON="󰁼"
    COLOR=0xffa6e3a1  # green
else
    ICON="󰁺"
    COLOR=0xfff38ba8  # red — critical
fi

sketchybar --set "$NAME" icon="$ICON" label="${PERCENTAGE}%" icon.color="$COLOR" label.color="$COLOR"
