#!/bin/bash

SOURCE_ID=$(defaults read com.apple.HIToolbox AppleCurrentKeyboardLayoutInputSourceID 2>/dev/null)
LANG=${SOURCE_ID##*.}

sketchybar --set "$NAME" label="${LANG:-?}"
