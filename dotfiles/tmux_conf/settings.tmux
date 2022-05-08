setw -g xterm-keys on
set -s escape-time 1 # Faster escape time
set -sg repeat-time 600 # Increase repeat timeout
set -s focus-events on

set -g history-limit 5000

# Terminal colors
set-option -ga terminal-overrides ",*256col*:Tc"
# Using xterm on local and screen on remote
if-shell -b 'test -f "$HOME/.remote_indicator"' 'set -g default-terminal "screen-256color"' 'set -g default-terminal "xterm-256color"'

# Faster status bar
set-option -g status-interval 10

# Hook _on_tmux_attach.sh
set-hook -g 'client-attached[10]' "run-shell $HOME/dotfiles_scripts/_on_tmux_attach.sh"

# Default shell in no_sudo
if-shell -b 'test -f "$HOME/.no_sudo_indicator"' 'set -g default-shell /bin/zsh'

# Enabling osc(remote) clipboard
set -g set-clipboard on

# Scroll with Mouse
set -g mouse on
