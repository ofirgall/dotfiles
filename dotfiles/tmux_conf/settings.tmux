setw -g xterm-keys on
set -s escape-time 1 # Faster escape time
set -sg repeat-time 600 # Increase repeat timeout
set -s focus-events on

# Disable activity events "{SESSION} is ready!"
set -g monitor-activity off
set -g monitor-bell off

set -g history-limit 5000

# Terminal Settings
# Using tmux-256color on local and screen-256color on remote
if-shell -b 'test -f "$HOME/.remote_indicator"' 'set -g default-terminal "screen-256color"' 'set -g default-terminal "tmux-256color"'
set -ga terminal-overrides ',*:RGB' # Enable 24 bit true colors
set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm' # Enable undercurl
set -sa terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m' # Enable undercurl colors

# Faster status bar
set-option -g status-interval 10

# Hook _on_tmux_attach.sh
set-hook -g 'client-attached[10]' "run-shell $HOME/dotfiles_scripts/inner/_on_tmux_attach.sh"

# Default shell in no_sudo
if-shell -b 'test -f "$HOME/.no_sudo_indicator"' 'set -g default-shell /bin/zsh'

# Enabling osc(remote) clipboard
set -g set-clipboard on

# Scroll with Mouse
set -g mouse on
