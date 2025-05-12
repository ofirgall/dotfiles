#!/usr/bin/env bash

if [[ -n "$1" && "$1" == "empty" ]]; then
    current_workspace=$(hyprctl activeworkspace -j | jq -r '.id')
    hyprctl dispatch renameworkspace "$current_workspace $current_workspace"
    exit
fi

current_session=$(tmux display-message -p '#S')
echo $current_session

if [[ "$current_session" == *"-viewer" ]]; then
    exit # Ignore viewer sessions
fi

current_workspace=$(hyprctl activeworkspace -j | jq -r '.id')
icon=""
hyprctl dispatch renameworkspace "$current_workspace $current_workspace $icon $current_session"
