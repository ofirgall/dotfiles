#!/bin/bash
# Minimize focused window and push its info onto a stack for later un-minimize.

STACK="/tmp/aerospace-minimized-stack"

INFO=$(aerospace list-windows --focused --format '%{window-id}|%{app-name}|%{window-title}' 2>/dev/null)

[ -z "$INFO" ] && exit 0

echo "$INFO" >> "$STACK"
aerospace macos-native-minimize
