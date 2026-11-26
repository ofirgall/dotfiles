#!/bin/bash

SSID=$(networksetup -getairportnetwork en0 2>/dev/null | awk -F': ' '{print $2}')

if [ -z "$SSID" ] || [ "$SSID" = "You are not associated with an AirPort network." ]; then
    sketchybar --set "$NAME" icon="󰤭" label="Off" icon.color=0xffcdd6f4 label.color=0xffcdd6f4
else
    sketchybar --set "$NAME" icon="󰤨" label="$SSID" icon.color=0xff94e2d5 label.color=0xff94e2d5
fi
