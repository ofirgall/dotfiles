#!/usr/bin/env bash

set -e

OPERATION=$1
CURRENT=$(xrandr --verbose | grep -i "brightness:" | grep -i -o "[0-9\.]*")

if [ -z "$OPERATION" ]; then
    echo "Current: $CURRENT"
    exit 0
fi

# Check for +/-, else set
if echo "$OPERATION" | grep -q "[+\-]"; then
    NEW_VAL=$(echo "$CURRENT $OPERATION" | bc -l | awk '{printf "%.4f\n", $0}')
else
    NEW_VAL=$1
fi

xrandr --output eDP-1 --brightness $NEW_VAL
