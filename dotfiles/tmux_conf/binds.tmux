#################
##### UTILS #####
#################
get_ssh_in_tty="ps -f -t '#{pane_tty}' | tail -n 1 | grep -o 'ssh.*'"
is_fzf="ps -o state= -o comm= -t '#{pane_tty}' | grep -q 'S fzf'"
is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
is_less="tmux capture-pane -p -t '#{pane_id}' | tail -n 1 | grep '^:$'"
is_nested_tmux="tmux capture-pane -p -t '#{pane_id}' | tail -n 1 | grep -E '.+'" # Matching my status line

##### MISC #####
# force Vi mode
set -g status-keys vi
set -g mode-keys vi


bind r source-file ~/.tmux.conf; display "Reloaded!"

# Fix end/home for xterm-256color
bind -n End send-key C-e
bind -n Home send-key C-a
bind -T suspended Home send-key C-a
bind -T suspended End send-key C-e

##### SPLIT PANES #####
# Splits windows with ALT+e/o
bind -n M-e split-window -h -c "#{pane_current_path}"
bind -n M-o split-window -v -c "#{pane_current_path}"
# Split windows and ssh to the remote that was connected
bind -r -T prefix e run-shell "$get_ssh_in_tty | xargs tmux split-window -h"
bind -r -T prefix o run-shell "$get_ssh_in_tty | xargs tmux split-window -v"

# Split window without activate it (I usually use it to swap hanging ssh)
bind -r -T prefix x run-shell "$get_ssh_in_tty | xargs tmux split-window -v -d"

# Kill pane with ALT+w
bind -n M-w kill-pane

##### PANE NAVIGATION #####
# Move around with alt+arrow/ctrl+hjkl
bind -n M-Left if-shell "$is_vim" 'send-keys M-Left'  'select-pane -L'
bind -n M-Down if-shell "$is_vim" 'send-keys M-Down'  'select-pane -D'
bind -n M-Up if-shell "$is_vim" 'send-keys M-Up'  'select-pane -U'
bind -n M-Right if-shell "$is_vim" 'send-keys M-Right'  'select-pane -R'

bind -n C-h if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
bind -n C-j if-shell "$is_vim || $is_fzf" 'send-keys C-j'  'select-pane -D'
bind -n C-k if-shell "$is_vim || $is_fzf" 'send-keys C-k'  'select-pane -U'
bind -n C-l if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'

# Override alt+up/down for copy-mode
bind -T copy-mode-vi M-Up select-pane -U
bind -T copy-mode-vi M-Down select-pane -D
bind -T copy-mode-vi M-Right select-pane -R
bind -T copy-mode-vi M-Left select-pane -L
bind -T copy-mode-vi C-h select-pane -L
bind -T copy-mode-vi C-l select-pane -R
bind -T copy-mode-vi C-k select-pane -U
bind -T copy-mode-vi C-j select-pane -D

##### PANE MANAGEMENT #####
# Resize pane with ctrl+arrow in prefix
bind -r -T prefix C-Left resize-pane -L 1
bind -r -T prefix C-Down resize-pane -D 1
bind -r -T prefix C-Up resize-pane -U 1
bind -r -T prefix C-Right resize-pane -R 1
bind -n M-z resize-pane -Z # Zoom/Unzoom pane
bind -T prefix = select-layout even-horizontal # Equally sized panes (like vim)
bind -T prefix + select-layout even-vertical # Equally sized panes (like vim)

# Swap panes with alt+arrow in prefix (ctrl+a/ctrl+b)
bind -r -T prefix M-Left swap-pane -s \{left-of\}
bind -r -T prefix M-Down swap-pane -s \{down-of\}
bind -r -T prefix M-Up swap-pane -s \{up-of\}
bind -r -T prefix M-Right swap-pane -s \{right-of\}

##### WINDOWS #####
# new window ALT+t
bind -n M-t new-window -c "#{pane_current_path}"

# Select windows by ALT+N
bind -n M-0 select-window -t :=10
bind -n M-1 select-window -t :=1
bind -n M-2 select-window -t :=2
bind -n M-3 select-window -t :=3
bind -n M-4 select-window -t :=4
bind -n M-5 select-window -t :=5
bind -n M-6 select-window -t :=6
bind -n M-7 select-window -t :=7
bind -n M-8 select-window -t :=8
bind -n M-9 select-window -t :=9
bind -n M-- last-window

bind -T copy-mode-vi M-0 select-window -t :=10
bind -T copy-mode-vi M-1 select-window -t :=1
bind -T copy-mode-vi M-2 select-window -t :=2
bind -T copy-mode-vi M-3 select-window -t :=3
bind -T copy-mode-vi M-4 select-window -t :=4
bind -T copy-mode-vi M-5 select-window -t :=5
bind -T copy-mode-vi M-6 select-window -t :=6
bind -T copy-mode-vi M-7 select-window -t :=7
bind -T copy-mode-vi M-8 select-window -t :=8
bind -T copy-mode-vi M-9 select-window -t :=9
bind -T copy-mode-vi M-- last-window

# Swap windows by ALT+SHIFT+N
bind -n M-) swap-window -d -t :=10
bind -n M-! swap-window -d -t :=1
bind -n M-@ swap-window -d -t :=2
bind -n M-'#' swap-window -d -t :=3
bind -n M-'$' swap-window -d -t :=4
bind -n M-% swap-window -d -t :=5
bind -n M-^ swap-window -d -t :=6
bind -n M-& swap-window -d -t :=7
bind -n M-* swap-window -d -t :=8
bind -n M-( swap-window -d -t :=9

##### WINDOW NAVIGATION #####
# Move between windows with ALT+PgUp/Down
bind -n M-PPage select-window -p
bind -n M-NPage select-window -n

# Alt+h/l - move tabs in tmux (outer binds)
# Alt+j/k - move tabs in vim (inner bind)
# Alt+u/i - move tabs in nested tmux
# Add +Shift to "Drag"
bind -n M-h select-window -p
bind -n M-l select-window -n
bind -n M-H swap-window -d -t -1
bind -n M-L swap-window -d -t +1
bind -n M-u if-shell "$is_nested_tmux" 'send-keys M-u' 'select-window -p'
bind -n M-i if-shell "$is_nested_tmux" 'send-keys M-i' 'select-window -n'
bind -n M-U if-shell "$is_nested_tmux" 'send-keys M-U' 'swap-window -d -t -1'
bind -n M-I if-shell "$is_nested_tmux" 'send-keys M-I' 'swap-window -d -t +1'

bind -T copy-mode-vi M-PPage select-window -p
bind -T copy-mode-vi M-NPage select-window -n
bind -T copy-mode-vi M-h select-window -p
bind -T copy-mode-vi M-l select-window -n
bind -T copy-mode-vi M-H swap-window -d -t -1
bind -T copy-mode-vi M-L swap-window -d -t +1

##### COPY MODE #####
# Start copy mode with Alt+c
# if nested:
# 	send M-c # copy-mode in nested session
# else:
# 	if is_less:
# 		copy-mode + go-to-top
# 	else
# 		copy-mode
bind -n M-c if-shell "$is_nested_tmux" 'send-keys M-c' "if-shell \"$is_less\" 'copy-mode; send-keys -X top-line' 'copy-mode'"

 # Start copy with Space
bind -T copy-mode-v Space send-keys -X begin-selection
 # Clear copy with c (stay in place)
bind -T copy-mode-vi c send-keys -X clear-selection
 # Cancel copy with Escape
bind -T copy-mode-vi Escape send-keys -X cancel
# Finish copy with Enter
bind -T copy-mode-vi Enter send-keys -X copy-selection-and-cancel

# Yank (without closing copy-mode) with y
bind -T copy-mode-vi y run-shell "tmux send-keys -X copy-pipe \"xclip -i -selection clipboard > /dev/null 2>&1\"; true"

##### MOUSE COPY MODE #####
# Copy word with double click
bind -n DoubleClick1Pane copy-mode -M \; send-keys -X select-word \; run-shell "sleep 0.2" \; send-keys -X copy-pipe-and-cancel

# Copy line with C-double click
bind -n DoubleClick1Pane copy-mode -M \; send-keys -X select-line \; run-shell "sleep 0.2" \; send-keys -X copy-pipe-and-cancel
# Copy word with double click
bind -n DoubleClick1Pane copy-mode -M \; send-keys -X select-word \; run-shell "sleep 0.2" \; send-keys -X copy-pipe-and-cancel

# Copy line with C-double click
bind -n DoubleClick1Pane copy-mode -M \; send-keys -X select-line \; run-shell "sleep 0.2" \; send-keys -X copy-pipe-and-cancel

# -------------------------
#	    PLUGINS BINDS
# -------------------------
##### TMUX-SUSPEND #####
# tmux-suspend, focus on nested ssh session (Alt+Enter)
set -g @suspend_key 'M-Enter'

##### TMUX-JUMP #####
# Tmux jump (like acejump or vimium) with ALT+j
bind -n M-s run-shell -b $HOME/.tmux/plugins/tmux-jump/scripts/tmux-jump.sh

##### TMUX-COPYCAT #####
# copy git file (after git status)
bind -n M-d if-shell "$is_vim" 'send-keys M-d' "run-shell $HOME/.tmux/plugins/tmux-copycat/scripts/copycat_git_special.sh #{pane_current_path}"

# copy url ALT+[
bind -n M-[ run-shell "$HOME/.tmux/plugins/tmux-copycat/scripts/copycat_mode_start.sh '(https?://|git@|git://|ssh://|ftp://|file:///)[[:alnum:]?=%/_.:,;~@!#$&()*+-]*'"

# copy Hashes
bind -n M-a run-shell "$HOME/.tmux/plugins/tmux-copycat/scripts/copycat_mode_start.sh '\\b([0-9a-f]{7,40}|[[:alnum:]]{52}|[0-9a-f]{64})\\b'"

# copy ip ALT+p
bind -n M-p run-shell "$HOME/.tmux/plugins/tmux-copycat/scripts/copycat_mode_start.sh '[[:digit:]]{1,3}\\.[[:digit:]]{1,3}\\.[[:digit:]]{1,3}\\.[[:digit:]]{1,3}'"

##### TMUX-OPEN #####
# Open text in google search
set -g @open-s 'https://www.google.com/search?q='

##### TMUX-FZF-URL #####
set -g @fzf-url-bind 'u'

##### TMUX-FUZZBACK #####
set -g @fuzzback-bind f

##### TMUX_CAPTURE_LAST_COMMAND_OUTPUT #####
set -g @command-capture-key l
