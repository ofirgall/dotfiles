setw -g xterm-keys on
set -s escape-time 10                     # faster command sequences
set -sg repeat-time 600                   # increase repeat timeout
set -s focus-events on
set -q -g status-utf8 on                  # expect UTF-8 (tmux < 2.2)
setw -q -g utf8 on

set -g history-limit 5000                 # boost history
set -g base-index 1           # start windows numbering at 1
setw -g pane-base-index 1     # make pane numbering consistent with windows
set -g renumber-windows on    # renumber windows when a window is closed
set -g display-panes-time 800 # slightly longer pane indicators display time
set -g display-time 1000      # slightly longer status messages display time

# activity
set -g monitor-activity on
set -g visual-activity off

# Terminal colors
# TODO: maybe need to change to allatricty or something
set-option -ga terminal-overrides ",*256col*:Tc"
# Using xterm on local and screen on remote
if-shell -b 'test -f "$HOME/.remote_indicator"' 'set -g default-terminal "screen-256color"' 'set -g default-terminal "xterm-256color"'

# Faster status bar
# set-option -g status-interval 10
set-option -g status-interval 2

# Hook _on_tmux_attach.sh
set-hook -g 'client-attached[10]' "run-shell $HOME/dotfiles_scripts/_on_tmux_attach.sh"

# Default shell in no_sudo
if-shell -b 'test -f "$HOME/.no_sudo_indicator"' 'set -g default-shell /bin/zsh'

# Enabling osc(remote) clipboard
set -g set-clipboard on

# Scroll with Mouse
set -g mouse on
