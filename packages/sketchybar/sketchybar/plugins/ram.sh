#!/bin/bash

STATS=$(vm_stat)
PAGESIZE=$(echo "$STATS" | head -1 | grep -o '[0-9]*')
ACTIVE=$(echo "$STATS" | awk '/Pages active/ {print $3}' | tr -d '.')
WIRED=$(echo "$STATS" | awk '/Pages wired/ {print $4}' | tr -d '.')
COMPRESSED=$(echo "$STATS" | awk '/Pages occupied by compressor/ {print $5}' | tr -d '.')
USED_MB=$(( (ACTIVE + WIRED + COMPRESSED) * PAGESIZE / 1024 / 1024 ))
TOTAL_MB=$(( $(sysctl -n hw.memsize) / 1024 / 1024 ))
PCT=$(( USED_MB * 100 / TOTAL_MB ))

sketchybar --set "$NAME" label="${PCT}%"
