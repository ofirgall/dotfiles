
tmux-window-name() {
	($TMUX_PLUGIN_MANAGER_PATH/tmux-window-name/scripts/rename_session_windows.py &)
}

if [ -n "$TMUX_PLUGIN_MANAGER_PATH" ]; then
	add-zsh-hook chpwd tmux-window-name
fi
