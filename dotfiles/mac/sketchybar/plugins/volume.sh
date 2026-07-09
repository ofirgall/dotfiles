#!/bin/bash

VOLUME=$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)
MUTED=$(osascript -e 'output muted of (get volume settings)' 2>/dev/null)

if [ "$MUTED" = "true" ] || [ "$VOLUME" = "0" ]; then
    ICON="󰝟"
    COLOR=0xfff38ba8  # red
elif [ "$VOLUME" -gt 66 ]; then
    ICON="󰕾"
    COLOR=0xff74c7ec  # sapphire
elif [ "$VOLUME" -gt 33 ]; then
    ICON="󰖀"
    COLOR=0xff74c7ec  # sapphire
else
    ICON="󰕿"
    COLOR=0xff74c7ec  # sapphire
fi

sketchybar --set "$NAME" icon="$ICON" label="${VOLUME}%" icon.color="$COLOR" label.color="$COLOR"
