#!/bin/bash
# Pre-compute workspace state for all groups with a single aerospace call.
# Writes /tmp/aerospace-ws-cache which sketchybar/plugins/aerospace.sh reads.
# Format: line 1 = focused group, lines 2+ = "GROUP HAS_WINDOWS WIN_COUNT [ICON...]"
# ICONs are sketchybar-app-font ligatures (e.g. :google_chrome:), one per unique app.

CACHE="/tmp/aerospace-ws-cache"
TMP_CACHE="${CACHE}.tmp.$$"

source "$HOME/dotfiles/dotfiles/mac/sketchybar/helpers/icon_map.sh"

FOCUSED_RAW=$(aerospace list-workspaces --focused 2>/dev/null)
FOCUSED_GROUP="${FOCUSED_RAW%%[bc]}"

COUNTS=()
ICONS=()
for i in 1 2 3 4 5 6 7 8 9 10; do COUNTS[i]=0; ICONS[i]=""; done

# Count windows per group; dedupe apps per group, keeping first-seen order
while IFS='|' read -r ws app; do
    group="${ws%%[bc]}"
    [[ "$group" =~ ^([1-9]|10)$ ]] || continue
    COUNTS[group]=$((COUNTS[group] + 1))
    __icon_map "$app"
    [[ " ${ICONS[group]} " == *" $icon_result "* ]] || ICONS[group]="${ICONS[group]} $icon_result"
done < <(aerospace list-windows --all --format '%{workspace}|%{app-name}' 2>/dev/null)

{
    echo "$FOCUSED_GROUP"
    for i in 1 2 3 4 5 6 7 8 9 10; do
        has=$(( COUNTS[i] > 0 ? 1 : 0 ))
        echo "$i $has ${COUNTS[i]}${ICONS[i]}"
    done
} > "$TMP_CACHE" && mv "$TMP_CACHE" "$CACHE"
