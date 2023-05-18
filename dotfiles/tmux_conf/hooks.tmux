current_tty="#{pane_tty}"
current_session="#S"
get_current_ssh_host="ps -f -t $current_tty | tail -n 1 | grep -o 'ssh .*' | cut -d' ' -f2"

set-hook -g 'pane-focus-in[1212]' "run-shell \"$get_current_ssh_host > /tmp/tmux_ssh_hosts_$current_session && tmux refresh\""
