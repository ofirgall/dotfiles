autoload -Uz add-zsh-hook

_asdf_update_path_for_repo() {
	local asdf_shims="${ASDF_DATA_DIR:-$HOME/.asdf}/shims"
	local repo_root

	path=("${(@)path:#$asdf_shims}")

	repo_root="$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null)" &&
		[[ -f "$repo_root/.tool-versions" ]] &&
		path=("$asdf_shims" $path)

	export PATH
}

add-zsh-hook chpwd _asdf_update_path_for_repo
_asdf_update_path_for_repo

tmux-window-name() {
	($TMUX_PLUGIN_MANAGER_PATH/tmux-window-name/scripts/rename_session_windows.py &)
}

if [ -n "$TMUX_PLUGIN_MANAGER_PATH" ]; then
	add-zsh-hook chpwd tmux-window-name
	source ~/.tmux/plugins/tmux-notify/shell/tmux-notify.zsh
fi
