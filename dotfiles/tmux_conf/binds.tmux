#################
##### UTILS #####
#################
current_tty="#{pane_tty}"
is_fzf="ps -o state= -o comm= -t '#{pane_tty}' | grep -q 'S fzf'"
is_nvim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|nvim?x?)(diff)?$'"
is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|vim?x?)(diff)?$'"
is_less="tmux capture-pane -p -t '#{pane_id}' | tail -n 1 | grep '^:$'"
is_nested_tmux="tmux capture-pane -p -t '#{pane_id}' | tail -n 1 | grep '' | grep ''" # Matching my status line
helpers="$HOME/.tmux_conf/helpers.sh"

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
# Binds for split/kill panes/windows are shared with nvim and remote nested sessions.
# There are 3 contexts we care about:
#	Inside nvim:
#		The keys are passed to nvim which is configured to do the equivalent action in nvim, e.g: Alt+e will create vertical split in nvim.
#		To send the action to tmux instead we add shift, e.g: Alt+shift+e will open tmux pane.

#	Inside nested-session: to control nested session panes we add shift to the action, alt+shift+e will open tmux pane in the nested session

#	Else: the action will be sent to tmux.

# Splits windows with ALT+e/o
bind -n M-e if-shell "$is_nvim || $is_nested_tmux" "send-keys M-e" 'split-window -h -c "#{pane_current_path}"'
bind -n M-o if-shell "$is_nvim || $is_nested_tmux" "send-keys M-o" 'split-window -v -c "#{pane_current_path}"'

bind -n M-E if-shell "$is_nvim || $is_nested_tmux" 'split-window -h -c "#{pane_current_path}"' 'send-keys M-E'
bind -n M-O if-shell "$is_nvim || $is_nested_tmux" 'split-window -v -c "#{pane_current_path}"' 'send-keys M-o'

# Kill pane with ALT+w
bind -n M-w if-shell "$is_nvim || $is_nested_tmux" "send-keys M-w" "run-shell ~/dotfiles_scripts/inner/kill_pane.sh"
bind -n M-W "kill-window"
# Kill pane with ALT+q
bind -n M-q if-shell "$is_nvim" "send-keys M-q" "run-shell ~/dotfiles_scripts/inner/kill_pane.sh"
bind -n M-Q if-shell "$is_nested_tmux" "send-keys M-q" "kill-window"

## Split windows to reconnect with ssh
# Split windows and ssh to the remote that was connected
bind -r -T prefix e run-shell "tmux split-window -h \"$($helpers get_ssh_cmd_in_pane #{pane_tty})\""
bind -r -T prefix o run-shell "tmux split-window -v \"$($helpers get_ssh_cmd_in_pane #{pane_tty})\""
bind -r -T prefix t run-shell "tmux new-window \"$($helpers get_ssh_cmd_in_pane #{pane_tty})\""

# Copy current ssh host
bind -r -T prefix c run-shell -b "echo \"$($helpers get_ssh_host_in_pane #{pane_tty})\" | toclip"

# Debug tty helpers
bind -r -T prefix D run-shell "tmux display-message #{pane_tty}"

# Split window without activate it (I usually use it to swap hanging ssh)
bind -r -T prefix x run-shell "tmux split-window -v -d \"$($helpers get_ssh_cmd_in_pane #{pane_tty})\""

##### PANE NAVIGATION #####
navigator="~/.config/awesome/tmux_focus.sh"
# Move around with alt+arrow/ctrl+hjkl
# bind -n C-h if-shell "$is_nvim" 'send-keys C-h'  'select-pane -L'
# bind -n C-j if-shell "$is_nvim || $is_fzf" 'send-keys C-j'  'select-pane -D'
# bind -n C-k if-shell "$is_nvim || $is_fzf" 'send-keys C-k'  'select-pane -U'
# bind -n C-l if-shell "$is_nvim" 'send-keys C-l'  'select-pane -R'

# For awesomewm-tmux-navigator (disables tmux zoom feature)
bind -n C-h if-shell "$is_nvim || $is_nested_tmux" 'send-keys C-h' "run-shell '$navigator left'"
bind -n C-j if-shell "$is_nvim || $is_nested_tmux || $is_fzf" 'send-keys C-j' "run-shell '$navigator down'"
bind -n C-k if-shell "$is_nvim || $is_nested_tmux || $is_fzf" 'send-keys C-k' "run-shell '$navigator up'"
bind -n C-l if-shell "$is_nvim || $is_nested_tmux" 'send-keys C-l' "run-shell '$navigator right'"
# Manually set M-hjkl keys if not in awesomewm
if-shell -b '[ "$XDG_SESSION_DESKTOP" != "awesome" ]' {
    bind -n M-h if-shell "$is_nvim || $is_nested_tmux" 'send-keys C-h' 'select-pane -L'
    bind -n M-j if-shell "$is_nvim || $is_nested_tmux || $is_fzf" 'send-keys C-j' 'select-pane -D'
    bind -n M-k if-shell "$is_nvim || $is_nested_tmux || $is_fzf" 'send-keys C-k' 'select-pane -U'
    bind -n M-l if-shell "$is_nvim || $is_nested_tmux" 'send-keys C-l' 'select-pane -R'
}

# Bind force navigation for alt+shift+hjkl
bind -n M-H run-shell "$navigator left"
bind -n M-J run-shell "$navigator down"
bind -n M-K run-shell "$navigator up"
bind -n M-L run-shell "$navigator right"

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
# Resize pane with ctrl+arrow/hjkl in prefix
bind -r -T prefix C-Left resize-pane -L 1
bind -r -T prefix C-Down resize-pane -D 1
bind -r -T prefix C-Up resize-pane -U 1
bind -r -T prefix C-Right resize-pane -R 1

bind -r -T prefix C-h resize-pane -L 1
bind -r -T prefix C-j resize-pane -D 1
bind -r -T prefix C-k resize-pane -U 1
bind -r -T prefix C-l resize-pane -R 1

# Swap panes with shift+arrow/hjkl in prefix
bind -r -T prefix S-Left swap-pane -s \{left-of\}
bind -r -T prefix S-Down swap-pane -s \{down-of\}
bind -r -T prefix S-Up swap-pane -s \{up-of\}
bind -r -T prefix S-Right swap-pane -s \{right-of\}

bind -r -T prefix H swap-pane -s \{left-of\}
bind -r -T prefix J swap-pane -s \{down-of\}
bind -r -T prefix K swap-pane -s \{up-of\}
bind -r -T prefix L swap-pane -s \{right-of\}

# Move panes with alt+shift/hjkl in prefix
bind -r -T prefix M-H move-pane -t '.{left-of}'
bind -r -T prefix M-J move-pane -h -t '.{down-of}'
bind -r -T prefix M-K move-pane -h -t '.{up-of}'
bind -r -T prefix M-L move-pane -t '.{right-of}'

bind -n M-z resize-pane -Z # Zoom/Unzoom pane
# Zoom/Unzoom remote pane with ALT+SHIFT+z
bind -n M-Z if-shell "$is_nvim" 'send-keys M-Z' 'send-keys M-z'
bind -T prefix = select-layout even-horizontal # Equally sized panes (like vim)
bind -T prefix + select-layout even-vertical # Equally sized panes (like vim)
bind -T prefix - select-layout tiled  # Equally sized panes (like vim)

##### WINDOWS #####
# new window ALT+t
bind -n M-t if-shell "$is_nested_tmux" 'send-keys M-t' 'new-window -c "#{pane_current_path}"'
# new window while in nested session ALT+SHIFT+t
bind -n M-T if-shell "$is_nested_tmux" 'new-window -c "#{pane_current_path}"' "if-shell \"$is_nvim\" 'send-keys M-t' 'send-keys M-T'"


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
bind -n C-Tab last-window
bind -n M-- last-window
bind -n M-` last-window

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
bind -T copy-mode-vi C-Tab last-window

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

# Alt+</> - move tabs in tmux
# Add +Shift to "Drag"
bind -n M-, select-window -p
bind -n M-. select-window -n
bind -n M-< swap-window -d -t -1
bind -n M-> swap-window -d -t +1
bind -n M-u if-shell "$is_nested_tmux" 'send-keys M-u' 'select-window -p'
bind -n M-i if-shell "$is_nested_tmux" 'send-keys M-i' 'select-window -n'
bind -n M-U if-shell "$is_nested_tmux" 'send-keys M-U' 'swap-window -d -t -1'
bind -n M-I if-shell "$is_nested_tmux" 'send-keys M-I' 'swap-window -d -t +1'

# Choose paste buffer
bind -T prefix '"' choose-buffer

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
# Copy with C-c
bind -T copy-mode-vi C-c send-keys -X copy-selection

# Yank (without closing copy-mode) with y
bind -T copy-mode-vi y run-shell "tmux send-keys -X copy-pipe \"xclip -i -selection clipboard > /dev/null 2>&1\"; true"

# Enter copy mode + scroll from root mode, Ignored when in nvim/less
bind -n C-u if-shell "$is_nvim || $is_vim || $is_nested_tmux || $is_less" "send-keys C-u" 'copy-mode; send-keys -X halfpage-up'

##### MOUSE COPY MODE #####
# Copy word with double click
bind -n DoubleClick1Pane if-shell "$is_nvim" "" 'copy-mode -M; send-keys -X select-word; run-shell "sleep 0.2"; send-keys -X copy-pipe-and-cancel'

# Dont finish copy when mouse drag end
unbind -T copy-mode-vi MouseDragEnd1Pane

# -------------------------
#	    MISC BINDS
# -------------------------
bind -n F12 if-shell "$is_nvim" "send-keys F12" 'setw synchronize-panes' # Toggle type on all panes

# -------------------------
#	    PLUGINS BINDS
# -------------------------
##### TMUX-THUMBS #####
# Copy fast with Alt+s
bind -n M-s if-shell "$is_nvim" "send-keys M-s" 'thumbs-pick'

##### TMUX-JUMP #####
# Tmux (like acejump or vimium) with ALT+shift+s
bind -n M-S run-shell -b $HOME/.tmux/plugins/tmux-jump/scripts/tmux-jump.sh

##### tmux-text-macros #####
open_macros="tmux split-window -v  \"PANE='#{pane_id}' $HOME/.tmux/plugins/tmux-text-macros/tmux-text-macros.tmux -r\""
# open macros menu with Alt+m except in nvim
bind -n M-m if-shell "$is_nvim" "send-keys M-m" 'run-shell $open_macros'

# open macros menu with Alt+shift+m anywhere
bind -n M-N run-shell $open_macros

bind -n M-R run-shell -b "TMUX_FZF_OPTIONS='-p -w 80% -h 80% -m' $HOME/.tmux/plugins/tmux-fzf/scripts/clipboard.sh buffer"

bind -n C-Space if-shell "$is_nvim" "send-keys C-Space" 'run-shell "$HOME/.tmux/plugins/extrakto/scripts/open.sh #{pane_id}"'
