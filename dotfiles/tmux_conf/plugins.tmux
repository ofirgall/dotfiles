
is_wsl="uname -a | grep Microsoft"

############################
##### PLUGINS SETTINGS #####
############################
set -g @continuum-restore 'on'
set -g @continuum-save-interval '1'
set -g @emulate-scroll-for-no-mouse-alternate-buffer "on"
set -g @tnotify-verbose 'on'
set -g @tnotify-verbose-msg '#S: #I #W is done!'
set -g @fzf-url-fzf-options '--reverse'
set -g @fuzzback-fzf-layout 'default'
set -g @command-capture-prompt-pattern ' $ '
set -g @thumbs-command 'echo -n {} | $HOME/dotfiles_scripts/misc/toclip; tmux display-message "Copied {}"'
set -g @resurrect-processes 'false' # Dont restore programs
set -g @tnotify-sleep-duration '2'
set -g @tmux_window_name_ignored_programs "['sqlite3']"
set -g @tmux_window_name_dir_programs "['nvim', 'git', 'fugitive', 'git_tree', 'kv']"
set -g @ttm-load-default-macros off # no default macros
set -g @ttm-window-mode 'vertical'
if-shell "$is_wsl" "set -g @browser_brotab_timeout '15.0'"
if-shell "$is_wsl" "set -g @browser_wait_timeout '15.0'"
set -g @new_browser_window 'vivaldi --new-window'
set -g @extrakto_split_direction 'p'
set -g @extrakto_clip_tool 'toclip'
set -g @extrakto_popup_size '50%'
set -g @extrakto_grab_area 'window full'
set -g @extrakto_copy_key 'y'
set -g @extrakto_insert_key 'enter'

# -------------------------
#	    PLUGINS BINDS
# -------------------------
##### TMUX-SUSPEND #####
# tmux-suspend, focus on nested ssh session (Alt+Enter)
set -g @suspend_key 'M-Enter'

##### TMUX-OPEN #####
# Open text in google search
set -g @open-s 'https://www.google.com/search?q='

##### TMUX-FZF-URL #####
set -g @fzf-url-bind 'u'

##### TMUX-FUZZBACK #####
set -g @fuzzback-bind f

##### TMUX_CAPTURE_LAST_COMMAND_OUTPUT #####
set -g @command-capture-key l

###################
##### PLUGINS #####
###################
set -g @plugin 'tmux-plugins/tmux-open'
set -g @plugin 'ofirgall/tmux-window-name'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'nhdaly/tmux-better-mouse-mode'
set -g @plugin 'MunifTanjim/tmux-suspend'
set -g @plugin 'ofirgall/tmux-browser'
set -g @plugin 'ofirgall/tmux-notify'
set -g @plugin 'wfxr/tmux-fzf-url'
set -g @plugin 'roosta/tmux-fuzzback'
set -g @plugin 'ofirgall/tmux_capture_last_command_output'
set -g @plugin 'fcsonline/tmux-thumbs'
set -g @plugin 'schasse/tmux-jump'
set -g @plugin 'Neo-Oli/tmux-text-macros'
set -g @plugin 'sainnhe/tmux-fzf'
set -g @plugin 'laktak/extrakto'

###########
# RUN TPM #
###########
run '$HOME/.tmux/plugins/tpm/tpm'
