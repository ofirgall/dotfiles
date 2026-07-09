#!/bin/bash

VOLUME=$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)
MUTED=$(osascript -e 'output muted of (get volume settings)' 2>/dev/null)

BT_AUDIO=$(system_profiler SPBluetoothDataType 2>/dev/null | grep -B5 "Connected: Yes" | grep -q "Minor Type: Headphones\|Minor Type: Headset\|Minor Type: Loudspeaker" && echo true || echo false)

if [ "$MUTED" = "true" ] || [ "$VOLUME" = "0" ]; then
    ICON="󰝟"
    COLOR=0xfff38ba8  # red
elif [ "$BT_AUDIO" = "true" ]; then
    ICON="󰂰"
    COLOR=0xfff5c2e7  # pink — bluetooth audio
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
