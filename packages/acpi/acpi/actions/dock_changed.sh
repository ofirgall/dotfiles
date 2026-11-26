#!/bin/sh

# export DISPLAY=:0
# logger "Changing autorandr config because of $1"
# (sleep 2 && sudo -u ofirg zsh -c "autorandr --change") &

# Reload virtual-desktops
logger "Reloading hyprland and virtual-desktops. Reason: $1"
$HOME/.config/hypr/scripts/Refresh.sh
