#!/bin/bash
set -e

# Sleep timers (minutes): 15 on battery, 30 on power adapter
sudo pmset -b displaysleep 15 sleep 15
sudo pmset -c displaysleep 30 sleep 30

# Key repeat rate, ~matching Hyprland (requires logout)
defaults write -g InitialKeyRepeat -int 13
defaults write -g KeyRepeat -int 2

# Fn Lock: F1-F12 act as standard function keys (media controls require Fn)
defaults write -g com.apple.keyboard.fnState -bool true

# Tap to Click on trackpad
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true

# Tap and drag: double-tap and hold to drag (without drag lock)
# This is the Accessibility > Pointer Control > Trackpad Options setting
defaults write com.apple.AppleMultitouchTrackpad Dragging -bool true
defaults write com.apple.AppleMultitouchTrackpad DragLock -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Dragging -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad DragLock -bool false

# Auto-hide Dock
defaults write com.apple.dock autohide -bool true
killall Dock
