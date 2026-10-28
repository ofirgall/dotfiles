#!/bin/bash
# Pre-compute workspace state for all groups with a single aerospace call.
# Writes /tmp/aerospace-ws-cache which sketchybar/plugins/aerospace.sh reads.
# Format: line 1 = focused group, lines 2+ = "GROUP DISPLAY HAS_WINDOWS WIN_COUNT ICONS|TAGS"
# DISPLAY is a sketchybar display arrangement-id; 0 aggregates all screens.
# ICONS are sketchybar-app-font ligatures (e.g. :google_chrome:), one per unique app,
# concatenated without spaces so they render tightly packed.
# TAGS are text names (e.g. "CI · Shraga") that tell Chrome profiles apart.

CACHE="/tmp/aerospace-ws-cache"
TMP_CACHE="${CACHE}.tmp.$$"
DISPLAY_CACHE="/tmp/sketchybar-display-info"

source "$HOME/dotfiles/dotfiles/mac/sketchybar/helpers/icon_map.sh"

FOCUSED_RAW=$(aerospace list-workspaces --focused 2>/dev/null)
FOCUSED_GROUP="${FOCUSED_RAW%%[bc]}"

# aerospace monitor-id N -> sketchybar display ID at index N-1 (from detect_displays.sh)
IFS=',' read -r -a MON_DISPLAYS <<< "$(sed -n '3p' "$DISPLAY_CACHE" 2>/dev/null)"

# Arrays indexed by GROUP*100 + DISPLAY
COUNTS=()
ICONS=()
TAGS=()
SEEN=()  # "|icon/tag|..." per key; exact match so untagged and tagged Chrome both show

add_app() {
    local key=$1
    COUNTS[key]=$(( ${COUNTS[key]:-0} + 1 ))
    [[ "${SEEN[key]}" == *"|$icon_result/$tag|"* ]] && return
    SEEN[key]="${SEEN[key]:-|}$icon_result/$tag|"
    ICONS[key]="${ICONS[key]}$icon_result"
    [ -n "$tag" ] && TAGS[key]="${TAGS[key]:+${TAGS[key]} · }$tag"
}

# Count windows per group and per screen; dedupe apps, keeping first-seen order
while IFS='|' read -r ws mon app title; do
    group="${ws%%[bc]}"
    [[ "$group" =~ ^([1-9]|10)$ ]] || continue
    # Local overrides on top of the vendored icon map
    tag=""
    case "$app" in
        Ghostty) icon_result=":rio:" ;;
        # Chrome profiles share one process; the window title ends with the profile name,
        # as "- <profile>" when signed out or "- <account> (<profile>)" when signed in
        "Google Chrome")
            # The getdrift.ai profiles share a name, so tell them apart by account
            case "$title" in
                *" - Person 1" | *"(Person 1)") icon_result=":whats_app:" ;;
                *" - Person 2" | *"(Person 2)") icon_result=":music:" ;;
                *" - CI (getdrift.ai)") icon_result=":google_chrome:"; tag="CI" ;;
                *" - Cursor (getdrift.ai)") icon_result=":google_chrome:"; tag="Shraga" ;;
                *" - getdrift.ai") icon_result=":google_chrome:"; tag="DriftMusic" ;;
                *) __icon_map "$app" ;;
            esac ;;
        *) __icon_map "$app" ;;
    esac
    add_app $(( group * 100 ))
    display="${MON_DISPLAYS[mon - 1]}"
    [ -n "$display" ] && add_app $(( group * 100 + display ))
done < <(aerospace list-windows --all --format '%{workspace}|%{monitor-id}|%{app-name}|%{window-title}' 2>/dev/null)

{
    echo "$FOCUSED_GROUP"
    for i in 1 2 3 4 5 6 7 8 9 10; do
        for d in 0 "${MON_DISPLAYS[@]}"; do
            key=$(( i * 100 + d ))
            count=${COUNTS[key]:-0}
            has=$(( count > 0 ? 1 : 0 ))
            echo "$i $d $has $count ${ICONS[key]}|${TAGS[key]}"
        done
    done
} > "$TMP_CACHE" && mv "$TMP_CACHE" "$CACHE"
