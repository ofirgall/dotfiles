### SETTINGS ###
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g display-panes-time 800
set -g display-time 1000
set -g monitor-activity off
set -g visual-activity off
set -g status-left-length 1000
set -g status-right-length 1000
set -g set-titles-string "#S - TMUX"
set -g set-titles on

set -q -g status-utf8 on
setw -q -g utf8 on

### PANE COLORS ###
set -g window-style 'bg=#000000'
set -g window-active-style 'bg=#000000'

### THEME ###
# Change @oasis_flavor to any dark or light variant, e.g. "night_dark", "canyon_light_3".
set -g @oasis_flavor "lagoon_dark"
set -g @oasis_mode_format "full"

### CUSTOM MODULES ###
# Must be set BEFORE oasis loads (its defaults use `-ogq`, so user values win).
helpers="$HOME/.tmux_conf/helpers.sh"

# Session: preserve design.tmux's drift-chore- strip + 35 char truncation.
set -g @oasis_module_session "\
#[fg=#{@thm_surface},bg=#{@thm_mantle}]\
#[bg=#{@thm_surface},fg=#{@thm_fg},bold] #{=35:#{s/^drift-chore-//:session_name}} \
#[fg=#{@thm_surface},bg=#{@thm_mantle}]"

# whoami
set -g @oasis_module_whoami "\
#[fg=#{@thm_surface},bg=#{@thm_mantle}]\
#[bg=#{@thm_surface},fg=#{@thm_fg}] #(whoami)@#h \
#[fg=#{@thm_surface},bg=#{@thm_mantle}]"

# current ssh - reads /tmp/tmux_ssh_hosts_<session>, hides when empty
set -g @oasis_module_current_ssh "\
#{?#{!=:#(cat /tmp/tmux_ssh_hosts_#S 2>/dev/null),},\
#[fg=#{@thm_primary},bg=#{@thm_mantle}]#[bg=#{@thm_primary},fg=#{@thm_core},bold] #(cat /tmp/tmux_ssh_hosts_#S) #[fg=#{@thm_primary},bg=#{@thm_mantle}]\
,}"

# github - hidden when helper outputs nothing
set -g @oasis_module_github "\
#{?#{!=:#(bash $helpers get_github_user_name),},\
#[fg=#{@thm_primary},bg=#{@thm_mantle}]#[bg=#{@thm_primary},fg=#{@thm_core},bold]  #(bash $helpers get_github_user_name) #[fg=#{@thm_primary},bg=#{@thm_mantle}]\
,}"

### STATUS BAR ###
set -g @oasis_status_left "#{E:@oasis_module_session}"

# Mode segment (covers nova's prefix + zoomed): shown only when not in normal mode.
set -g @oasis_status_right "\
#{?#{||:#{client_prefix},#{||:#{pane_in_mode},#{window_zoomed_flag}}},#{E:@oasis_module_mode},}\
#{E:@oasis_module_sync}\
#{E:@oasis_module_github}\
#{E:@oasis_module_current_ssh}\
#{E:@oasis_module_whoami}"

### PLUGIN ###
set -g @plugin 'ofirgall/tmux-oasis'
# source-file "$HOME/.tmux/plugins/tmux-oasis/entrypoint.tmux"
