current_tty="#{pane_tty}"
current_session="#S"
get_current_ssh_host="$HOME/.tmux_conf/helpers.sh get_ssh_host_in_pane $current_tty"
cut_ssh_hostname="cut -c1-32"

set-hook -g 'pane-focus-in[1212]' "run-shell \"$get_current_ssh_host | $cut_ssh_hostname > /tmp/tmux_ssh_hosts_$current_session && tmux refresh\""

set -g @resurrect-hook-post-save-layout "$HOME/dotfiles_scripts/tmux/save_current_attached.sh"
# set -g @resurrect-hook-pre-restore-pane-processes "echo > /tmp/tmux_ressurect_done"
