#!/usr/bin/env sh

xset r rate 200 35 # Faster repeat rate
setxkbmap -option caps:escape # Capslock to escape

xinput set-prop "DELL0A36:00 0488:101A Touchpad" 325 1 # Natural scrolling
xinput set-prop "DELL0A36:00 0488:101A Touchpad" 348 1 # Tapping enabled

# Mouse speed at home
xinput --set-prop 'Glorious Model O Wireless' 'libinput Accel Speed' -0.3

# Mouse speed at work
xinput --set-prop 'pointer:Logitech MX Master 3' 'libinput Accel Speed' -0.5

xmodmap ~/.xmodmaprc 2> /dev/null # key mapping, xev to see keys
