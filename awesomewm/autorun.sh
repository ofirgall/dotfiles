#!/usr/bin/env sh

xset r rate 200 35 # Faster repeat rate
setxkbmap -option caps:escape # Capslock to escape

# Touchpad
xinput set-prop "ELAN06A1:00 04F3:3232 Touchpad" "libinput Natural Scrolling Enabled" 1
xinput set-prop "ELAN06A1:00 04F3:3232 Touchpad" "libinput Tapping Enabled" 1
xinput set-prop "ELAN06A1:00 04F3:3232 Touchpad" "libinput Scrolling Pixel Distance" 40
xinput set-prop "ELAN06A1:00 04F3:3232 Touchpad" "libinput High Resolution Wheel Scroll Enabled" 0
xinput --set-prop 'ELAN06A1:00 04F3:3232 Touchpad' 'libinput Accel Speed' 0.34

# Home ThinkPad
xinput set-prop "Synaptics TM3276-022" "libinput Natural Scrolling Enabled" 1
xinput set-prop "Synaptics TM3276-022" "libinput Tapping Enabled" 1
xinput set-prop "Synaptics TM3276-022" "libinput Scrolling Pixel Distance" 30
xinput set-prop "Synaptics TM3276-022" "libinput High Resolution Wheel Scroll Enabled" 0
xinput set-prop "Synaptics TM3276-022" 'libinput Accel Speed' 0.25

# Mouse speed at home
xinput --set-prop 'Glorious Model O Wireless' 'libinput Accel Speed' -0.35

# Mouse speed at work
xinput --set-prop 'pointer:Logitech MX Master 3' 'libinput Accel Speed' -0.6

xmodmap ~/.xmodmaprc 2> /dev/null # key mapping, xev to see keys

# Start user services at ~/.config/systemd/user
systemctl --user start $(ls ~/.config/systemd/user/* | xargs basename)

echo 'done'
