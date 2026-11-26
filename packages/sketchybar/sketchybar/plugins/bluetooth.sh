#!/bin/bash

BT_STATE=$(defaults read /Library/Preferences/com.apple.Bluetooth ControllerPowerState 2>/dev/null)

if [ "$BT_STATE" = "1" ]; then
    sketchybar --set "$NAME" icon="󰂯" label="On"
else
    sketchybar --set "$NAME" icon="󰂲" label="Off"
fi
