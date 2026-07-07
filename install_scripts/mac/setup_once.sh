#!/bin/bash
set -e

# Sleep timers (minutes): 15 on battery, 30 on power adapter
sudo pmset -b displaysleep 15 sleep 15
sudo pmset -c displaysleep 30 sleep 30

# Key repeat rate, ~matching Hyprland (requires logout)
defaults write -g InitialKeyRepeat -int 13
defaults write -g KeyRepeat -int 2
