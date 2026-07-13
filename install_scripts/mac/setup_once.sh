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

# Hide native menu bar (replaced by SketchyBar)
defaults write NSGlobalDomain _HIHideMenuBar -bool true

# Tap to Click on trackpad
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true

# Tap and drag: double-tap and hold to drag (without drag lock)
# This is the Accessibility > Pointer Control > Trackpad Options setting
defaults write com.apple.AppleMultitouchTrackpad Dragging -bool true
defaults write com.apple.AppleMultitouchTrackpad DragLock -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Dragging -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad DragLock -bool false

# Disable Spotlight shortcut (Cmd+Space) — replaced by Raycast
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 '{"enabled" = 0; "value" = {"parameters" = (32, 49, 1048576); "type" = "standard";};}'
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 65 '{"enabled" = 0; "value" = {"parameters" = (32, 49, 1572864); "type" = "standard";};}'

# Disable Ctrl+Space input source switching (let it pass to tmux)
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 60 '{"enabled" = 0; "value" = {"parameters" = (32, 49, 262144); "type" = "standard";};}'
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 61 '{"enabled" = 0; "value" = {"parameters" = (32, 49, 393216); "type" = "standard";};}'

# Disable screenshot shortcuts (Cmd+Shift+3/4/5) — conflicts with aerospace workspace binds
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 28 '{ enabled = 0; }'
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 30 '{ enabled = 0; }'
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 184 '{ enabled = 0; }'

# Auto-hide Dock
defaults write com.apple.dock autohide -bool true
killall Dock

# Cursor: size 1.75x, white fill, black outline
sudo defaults write com.apple.universalaccess mouseDriverCursorSize -float 1.75
sudo defaults write com.apple.universalaccess cursorFill -dict alpha -float 1 blue -float 1 green -float 1 red -float 1
sudo defaults write com.apple.universalaccess cursorOutline -dict alpha -float 1 blue -float 0 green -float 0 red -float 0

