autoload -Uz add-zsh-hook

_asdf_update_path_for_repo() {
	local asdf_shims="${ASDF_DATA_DIR:-$HOME/.asdf}/shims"
	local repo_root

	path=("${(@)path:#$asdf_shims}")

	repo_root="$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null)"

	if [[ -n "$repo_root" && -f "$repo_root/.tool-versions" ]]; then
		path=("$asdf_shims" $path)

		# Atlas is excluded from asdf (fragile plugin) and resolved via ensure-atlas.sh
		local atlas_bin_dir="$repo_root/IaC/local-dev/.bin"
		path=("${(@)path:#$atlas_bin_dir}")
		[[ -d "$atlas_bin_dir" ]] && path=("$atlas_bin_dir" $path)
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
