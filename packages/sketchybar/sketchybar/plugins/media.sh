#!/bin/bash

SPOTIFY_RUNNING=$(pgrep -x Spotify >/dev/null 2>&1 && echo true || echo false)
MUSIC_RUNNING=$(pgrep -x Music >/dev/null 2>&1 && echo true || echo false)

if [ "$SPOTIFY_RUNNING" = "true" ]; then
    STATE=$(osascript -e 'tell application "Spotify" to player state as string' 2>/dev/null)
    if [ "$STATE" = "playing" ] || [ "$STATE" = "paused" ]; then
        TRACK=$(osascript -e 'tell application "Spotify" to name of current track' 2>/dev/null)
        ARTIST=$(osascript -e 'tell application "Spotify" to artist of current track' 2>/dev/null)
        ICON=$( [ "$STATE" = "playing" ] && echo "󰎆" || echo "󰏤" )
        sketchybar --set "$NAME" icon="$ICON" label="${ARTIST} — ${TRACK}" drawing=on
        exit 0
    fi
elif [ "$MUSIC_RUNNING" = "true" ]; then
    STATE=$(osascript -e 'tell application "Music" to player state as string' 2>/dev/null)
    if [ "$STATE" = "playing" ] || [ "$STATE" = "paused" ]; then
        TRACK=$(osascript -e 'tell application "Music" to name of current track' 2>/dev/null)
        ARTIST=$(osascript -e 'tell application "Music" to artist of current track' 2>/dev/null)
        ICON=$( [ "$STATE" = "playing" ] && echo "󰎆" || echo "󰏤" )
        sketchybar --set "$NAME" icon="$ICON" label="${ARTIST} — ${TRACK}" drawing=on
        exit 0
    fi
fi

sketchybar --set "$NAME" drawing=off
