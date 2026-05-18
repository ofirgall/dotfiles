
is_wsl="uname -a | grep Microsoft"

############################
##### PLUGINS SETTINGS #####
############################
set -g @continuum-restore 'on'
set -g @continuum-save-interval '1'
set -g @emulate-scroll-for-no-mouse-alternate-buffer "on"
set -g @fzf-url-fzf-options '--tmux center,50%,50% --multi --exit-0 --no-preview'
set -g @fuzzback-fzf-layout 'default'
set -g @resurrect-processes 'false' # Dont restore programs
set -g @tmux_window_name_ignored_programs "['sqlite3']"
set -g @tmux_window_name_dir_programs "['nvim', 'git', 'fugitive', 'git_tree', 'kv', 'yazi']"
set -g @tmux_window_name_icon_style "'dir_and_icon'"
set -g @tmux_window_name_custom_icons '{"python": "🐍", "kv": ""}'
set -g @tmux_window_name_ignore_program_diffs "True"
set -g @ttm-load-default-macros off # no default macros
set -g @ttm-window-mode 'vertical'
if-shell "$is_wsl" "set -g @browser_brotab_timeout '15.0'"
if-shell "$is_wsl" "set -g @browser_wait_timeout '15.0'"
set -g @new_browser_window 'google-chrome --new-window'
set -g @extrakto_split_direction 'p'
set -g @extrakto_clip_tool 'toclip'
set -g @extrakto_popup_size '50%'
set -g @extrakto_grab_area 'window full'
set -g @extrakto_copy_key 'tab'
set -g @extrakto_insert_key 'enter'
set -g @tnotify-shell-integration 'on'
set -g @tnotify-verbose 'on'
set -g @tnotify-verbose-msg 'Session #S|#I\n#{tnotify_command} finished'
set -g @tnotify-urgency 'critical'
set -g @tnotify-on-start  '$HOME/.tmux_conf/tnotify_on_start.sh'
set -g @tnotify-on-finish '$HOME/.tmux_conf/tnotify_on_finish.sh'
set -g @tnotify-on-cancel '$HOME/.tmux_conf/tnotify_on_finish.sh'

# New settings
set -g @fuzzback-popup 1
set -g @fuzzback-popup-size '70%'

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
set -g @plugin 'wfxr/tmux-fzf-url'
set -g @plugin 'roosta/tmux-fuzzback'
set -g @plugin 'Neo-Oli/tmux-text-macros'
set -g @plugin 'sainnhe/tmux-fzf'
set -g @plugin 'laktak/extrakto'
set -g @plugin 'aless3/tmux-click-copy'
set -g @plugin 'KoalaVim/tmux-notify'

###########
# RUN TPM #
###########
run '$HOME/.tmux/plugins/tpm/tpm'
