autoload -Uz add-zsh-hook

_asdf_enabled_repos=(
	"drift-team/drift"
)

_asdf_update_path_for_repo() {
	local asdf_shims="${ASDF_DATA_DIR:-$HOME/.asdf}/shims"
	local remotes allowed_repo

	path=("${(@)path:#$asdf_shims}")

	if [[ -d "$asdf_shims" ]]; then
		remotes="$(git -C "$PWD" remote -v 2>/dev/null)"
		for allowed_repo in "${_asdf_enabled_repos[@]}"; do
			if [[ "$remotes" == *"$allowed_repo"* ]]; then
				path=("$asdf_shims" $path)
				break
			fi
		done
	fi

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
