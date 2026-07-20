current_tty="#{pane_tty}"
current_session="#S"
get_current_ssh_host="$HOME/.tmux_conf/helpers.sh get_ssh_host_in_pane $current_tty"
cut_ssh_hostname="cut -c1-32"

set-hook -g 'client-attached[1212]' 'run-shell -b "if [ \"$(uname)\" = Darwin ]; then /opt/homebrew/bin/python3.14 $HOME/agents-status/statusbar/run.py; elif [ -n \"$MSYSTEM\" ]; then python3 $HOME/agents-status/statusbar/run.py; else $HOME/.config/hypr/UserScripts/RenameWorkspaces.py; fi"'
set-hook -g 'client-detached[1212]' 'run-shell -b "if [ \"$(uname)\" = Darwin ]; then /opt/homebrew/bin/python3.14 $HOME/agents-status/statusbar/run.py; elif [ -n \"$MSYSTEM\" ]; then python3 $HOME/agents-status/statusbar/run.py; else $HOME/.config/hypr/UserScripts/RenameWorkspaces.py; fi"'

set -g @resurrect-hook-post-save-layout "$HOME/dotfiles_scripts/tmux/save_current_attached.sh"
# set -g @resurrect-hook-pre-restore-pane-processes "echo > /tmp/tmux_ressurect_done"

set-hook -g 'pane-focus-in[1212]' "run-shell \"$get_current_ssh_host | $cut_ssh_hostname > /tmp/tmux_ssh_hosts_$current_session && tmux refresh\""

# Keep @window_color_active (the dim variant) in sync with @window_color
# for every window. Fires on any window selection so manual
# `tmux setw @window_color X` is picked up automatically once the user
# switches windows.
refresh_dim_colors="$HOME/agents-status/tmux/scripts/refresh_dim_colors.sh"
set-hook -g after-select-window "run-shell -b $refresh_dim_colors"
set-hook -g window-linked        "run-shell -b $refresh_dim_colors"
set-hook -g session-created      "run-shell -b $refresh_dim_colors"
set-hook -g client-attached      "run-shell -b $refresh_dim_colors"
