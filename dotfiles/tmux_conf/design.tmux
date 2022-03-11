### PLUGINS ###
set -g @plugin 'o0th/tmux-nova'
set -g @plugin 'tmux-plugins/tmux-cpu'
set -g @plugin 'tmux-plugins/tmux-battery'
set -g @plugin 'ofirgall/tmux-keyboard-layout'

### SETTINGS ###
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g display-panes-time 800
set -g display-time 1000
set -g monitor-activity off
set -g visual-activity off

set -q -g status-utf8 on
setw -q -g utf8 on

### THEME ###
set -g @nova-nerdfonts true
set -g @nova-nerdfonts-left 
set -g @nova-nerdfonts-right 

set -g @nova-pane "#I  #W"
set -g @nova-rows 0

### COLORS ###
b_bg="#504945"

seg_a="#a89984 #282828"
seg_b="$b_bg #ddc7a1"

inactive_bg="#32302f"
inactive_fg="#ddc7a1"
active_bg=$b_bg
active_fg="#f2e8d5"

suspended_inactive_bg="#1f1c1b"
suspended_inactive_fg="#000000"
suspended_active_bg="#2b2726"
suspended_active_fg="#000000"

set -g "@nova-status-style-bg" "$inactive_bg"
set -g "@nova-status-style-fg" "$inactive_fg"
set -g "@nova-status-style-active-bg" "$active_bg"
set -g "@nova-status-style-active-fg" "$active_fg"

set -g "@nova-pane-active-border-style" "#44475a"
set -g "@nova-pane-border-style" "#827d51"

### STATUS BAR ###
set -g @nova-segment-prefix "#{?client_prefix,PREFIX,}"
set -g @nova-segment-prefix-colors "$seg_b"

set -g @nova-segment-session "#{session_name}"
set -g @nova-segment-session-colors "$seg_a"

set -g @nova-segment-whoami "#(whoami)@#h"
set -g @nova-segment-whoami-colors "$seg_a"

set -g @nova-segment-cpu " #(~/.tmux/plugins/tmux-cpu/scripts/cpu_percentage.sh) #(~/.tmux/plugins/tmux-cpu/scripts/ram_percentage.sh)"
set -g @nova-segment-cpu-colors "$seg_b"

set -g @batt_icon_status_charging '↑'
set -g @batt_icon_status_discharging '↓'
set -g @nova-segment-battery "#{battery_icon_status} #{battery_percentage}"
set -g @nova-segment-battery-colors "$seg_b"

set -g @nova-segment-layout "#(~/.tmux/plugins/tmux-keyboard-layout/scripts/get_keyboard_layout.sh)"
set -g @nova-segment-layout-colors "$seg_a"

set -g @nova-segment-suspended "#{@suspended_mode}"
set -g @nova-segment-suspended-colors "$seg_a"

set -g @nova-segments-0-left "session"
set -g @nova-segments-0-right "prefix cpu battery layout whoami"

### SUSPENDED MODE ###
set -g @suspend_on_resume_command "tmux \
	set -g '@nova-status-style-bg' '$inactive_bg' \\; \
	set -g '@nova-status-style-fg' '$inactive_fg' \\; \
	set -g '@nova-status-style-active-bg' '$active_bg' \\; \
	set -g '@nova-status-style-active-fg' '$active_fg' \\; \
	run -b 'bash $HOME/.tmux/plugins/tmux-nova/scripts/nova.sh'"

set -g @suspend_on_suspend_command "tmux \
	set -g '@nova-status-style-bg' '$suspended_inactive_bg' \\; \
	set -g '@nova-status-style-fg' '$suspended_inactive_fg' \\; \
	set -g '@nova-status-style-active-bg' '$suspended_active_bg' \\; \
	set -g '@nova-status-style-active-fg' '$suspended_active_fg' \\; \
	run -b 'bash $HOME/.tmux/plugins/tmux-nova/scripts/nova.sh'"
