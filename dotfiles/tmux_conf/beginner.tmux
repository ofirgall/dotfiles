######################
###    README      ###
######################
# This file is a beginner tmux config that aims terminator immigrants, place it as ~/.tmux.conf
#
# tmux is consists `sessions` which consists `windows` which consists `panes`
#	session: Set of windows, you can name the session as you want.
#			 You can attach and de-attach from sessions.
#			 The session can be saved/restored.
#			 Personally I use session per git-repo I use and some extra but you can use it as you want.
#
#	window: Set of panes, you can think as a terminal tab
#
#	pane: Is a terminal "window", the shell runs in the pane
#
#
# How binds works in tmux:
#	tmux eventually is TUI (terminal ui) program, which reads the keys that send to the terminal.
#	It can't bind to the system shortcut like a normal GUI, so the keys are passed from the `terminal-emulator`
#	In ubuntu it looks something like that:
#		GNOME Desktop -> GNOME Terminal (could be terminator or other terminal emulator) -> tmux -> your shell
#	The terminal emulator can be whatever you like I recommend to use alacritty.
#
# Tmux `mode` system:
#	tmux has a `mode` system, each `mode` has his own bind table.
#	The modes:
#		- root: The "normal" mode, by default nothing binded in this mode, but getting into `prefix` mode.
#		- prefix: By default the actual features are binded in tmux, e.g: create new window or create pane.
#					To get in `prefix` mode press Ctrl+b in `root` mode
#		- copy-mode: "de-attach" your cursor and let you copy text from the terminal.
#		- copy-mode-vi: like `copy-mode` but with vi(m) binds.
#
# The keys that sent to the terminal are in ASCII and looks like that:
#	a: `a`
#	Shift+a: `A`
#	Alt+a: `M-a`
#	Alt+Shift+a: M-A`
#	Ctrl+a: `C-a`
#	Ctrl+shift+a: N/A by default, terminal emulators doesn't send this keys because of ANSI limitations
#
# How to bind a key:
#	> bind -T <mode_table> <key sequence> <tmux command>
#	Example of bind vertical split on `Alt+e` in `root`:
#		bind -T root M-e split-window -h
#		bind -n M-e split-window -h # Does the same but using -n instead of -T root
#	Example of bind vertical split on `e` in `prefix`:
#		bind -T prefix e split-window -h
#
# To see all the binded keys you can run `tmux list-keys` which output this format:
#	bind-key	-T <mode_table>		<Key sequence>	<tmux command>
#
# Tmux Commands:
#	Every tmux action is eventually runs by a `tmux command` to see all the commands look at `man tmux`
#	You can run command from the shell by `tmux <tmux-command>`.
#	You can run command in prefix mode, press `:` and then type the command.
#	You can run command from key-binds as we mentioned before.
#
#
# Tmux Plugins:
#	One of the great features of tmux is that is extensible.
#	The plugin manager of tmux is called tpm and you install it by running `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`
#	To reload the plugins hit `shift+i` in `prefix mode`
#
#	To add a plugin add this line to the config:
#		set -g @plugin 'tmux-plugins/tmux-resurrect'
#	This will add `https://github.com/tmux-plugins/tmux-resurrect`
#
#	Where to find plugins:
#		https://github.com/rothgar/awesome-tmux
#		https://github.com/tmux-plugins/list
#
#	Recommended Plugins:
#		https://github.com/tmux-plugins/tmux-resurrect - Restore/Save tmux sessions
#		https://github.com/tmux-plugins/tmux-continuum - Auto trigger for `tmux-resurrect`
#		https://github.com/arcticicestudio/nord-tmux - Good tmux theme, need to install nord fonts to make it work.
#		https://github.com/ofirgall/tmux-window-name - Names the tmux windows automatically (by me :])
#		You can check out `plugins.tmux` in this repo to look at what I use.
#
# FIXME: there are `XXX` comments in this file, go over them before starting.

######################
### BASIC SETTINGS ###
######################
setw -g xterm-keys on
set -s escape-time 1 # Faster escape time
set -sg repeat-time 600 # Increase repeat timeout
set -s focus-events on

set -g history-limit 5000
set-option -g status-interval 10
set -g set-clipboard on # Copy to OS clipboard
set -g mouse on


#######################
### DESIGN SETTINGS ###
#######################
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g display-panes-time 800
set -g display-time 1000
set -g monitor-activity off
set -g visual-activity off
set -g status-left-length 1000
set -g status-right-length 1000
set -q -g status-utf8 on
setw -q -g utf8 on

##########################
### RECOMMENDE PLUGINS ###
##########################
set -g @continuum-restore 'on'
set -g @continuum-save-interval '1'

set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'ofirgall/tmux-window-name'
set -g @plugin 'arcticicestudio/nord-tmux'

run '$HOME/.tmux/plugins/tpm/tpm' # run tpm after everything all plugins set

######################
###     BINDS      ###
######################
# which copy-mode to use, emacs or vim
# if you are vim user use vim otherwise I suggest to choose emacs
# XXX: CHOOSE emacs
	set -g status-keys emacs
    set -g mode-keys emacs
# set -g status-keys vi
# set -g mode-keys vi

# Reload your tmux config
bind r source-file ~/.tmux.conf; display "Reloaded!"
# XXX: To reload/download plugins hit shift+I in prefix mode

# Fix end/home for xterm-256color
bind -n End send-key C-e
bind -n Home send-key C-a
bind -T suspended Home send-key C-a
bind -T suspended End send-key C-e

##### SPLIT PANES #####
# Create new pane with Alt+e (vertical) Alt+o (horizontal), inspired by terminator
bind -n M-e split-window -h -c "#{pane_current_path}"
bind -n M-o split-window -v -c "#{pane_current_path}"

# Kill pane with ALT+w
bind -n M-w kill-pane

##### PANE NAVIGATION #####
# Move around panes with alt+arrow/ctrl+hjkl
bind -n M-Left select-pane -L
bind -n M-Down select-pane -D
bind -n M-Up select-pane -U
bind -n M-Right select-pane -R

bind -n C-h select-pane -L
bind -n C-j select-pane -D
bind -n C-k select-pane -U
bind -n C-l select-pane -R

# Move around panes while in copy-mode
bind -T copy-mode M-Up select-pane -U
bind -T copy-mode M-Down select-pane -D
bind -T copy-mode M-Right select-pane -R
bind -T copy-mode M-Left select-pane -L
bind -T copy-mode C-h select-pane -L
bind -T copy-mode C-l select-pane -R
bind -T copy-mode C-k select-pane -U
bind -T copy-mode C-j select-pane -D

##### WINDOWS #####
# new window ALT+t
bind -n M-t new-window -c "#{pane_current_path}"

# Select windows by ALT+Number
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

bind -T copy-mode M-0 select-window -t :=10
bind -T copy-mode M-1 select-window -t :=1
bind -T copy-mode M-2 select-window -t :=2
bind -T copy-mode M-3 select-window -t :=3
bind -T copy-mode M-4 select-window -t :=4
bind -T copy-mode M-5 select-window -t :=5
bind -T copy-mode M-6 select-window -t :=6
bind -T copy-mode M-7 select-window -t :=7
bind -T copy-mode M-8 select-window -t :=8
bind -T copy-mode M-9 select-window -t :=9
bind -T copy-mode M-- last-window

# Swap windows by ALT+SHIFT+Number
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
bind -T copy-mode M-PPage select-window -p
bind -T copy-mode M-NPage select-window -n

##### PANE MANAGEMENT #####
# Resize pane with ctrl+arrow in prefix
bind -r -T prefix C-Left resize-pane -L 1
bind -r -T prefix C-Down resize-pane -D 1
bind -r -T prefix C-Up resize-pane -U 1
bind -r -T prefix C-Right resize-pane -R 1
bind -n M-z resize-pane -Z # Zoom/Unzoom pane (Focus)

# Swap panes with alt+arrow in prefix
bind -r -T prefix M-Left swap-pane -s \{left-of\}
bind -r -T prefix M-Down swap-pane -s \{down-of\}
bind -r -T prefix M-Up swap-pane -s \{up-of\}
bind -r -T prefix M-Right swap-pane -s \{right-of\}

##### COPY MODE #####
# Skip words with C+Left/Right
bind -T copy-mode C-Left send-keys -X previous-word
bind -T copy-mode C-Right send-keys -X next-word-end

bind -n M-c copy-mode

 # Start copy with Space
bind -T copy-mode-v Space send-keys -X begin-selection
 # Clear copy with c (stay in place)
bind -T copy-mode c send-keys -X clear-selection
 # Cancel copy with Escape
bind -T copy-mode Escape send-keys -X cancel
# Finish copy with Enter
bind -T copy-mode Enter send-keys -X copy-selection-and-cancel

# Yank (without closing copy-mode) with y
bind -T copy-mode y run-shell "tmux send-keys -X copy-pipe \"xclip -i -selection clipboard > /dev/null 2>&1\"; true"

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

##### TMUX-THUMBS #####
# Copy fast with Alt+s
bind -n M-s thumbs-pick

##### TMUX-JUMP #####
# Tmux (like acejump or vimium) with ALT+shift+s
bind -n M-S run-shell -b /home/ogal/.tmux/plugins/tmux-jump/scripts/tmux-jump.sh

##### TMUX-OPEN #####
# Open text in google search
set -g @open-s 'https://www.google.com/search?q='

##### TMUX-FZF-URL #####
set -g @fzf-url-bind 'u'

##### TMUX-FUZZBACK #####
set -g @fuzzback-bind f

##### TMUX_CAPTURE_LAST_COMMAND_OUTPUT #####
set -g @command-capture-key l

##### tmux-text-macros #####
# open macros menu with Alt+shift+m
bind -n M-M run-shell "tmux split-window -v  \"PANE='#{pane_id}' /home/ogal/.tmux/plugins/tmux-text-macros/tmux-text-macros.tmux -r\""
