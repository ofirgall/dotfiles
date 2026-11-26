autoload -Uz add-zsh-hook

source "${${(%):-%x}:A:h}/asdf.zsh"

tmux-window-name() {
	($TMUX_PLUGIN_MANAGER_PATH/tmux-window-name/scripts/rename_session_windows.py &)
}

if [ -n "$TMUX_PLUGIN_MANAGER_PATH" ]; then
	add-zsh-hook chpwd tmux-window-name
	source ~/.tmux/plugins/tmux-notify/shell/tmux-notify.zsh
fi

# Start herdr-last-tab daemon (once per server)
if [[ -n "${HERDR_PANE_ID:-}" ]]; then
	local _pid_file="/tmp/herdr-last-tab/daemon.pid"
	if ! { [[ -f "$_pid_file" ]] && kill -0 "$(<$_pid_file)" 2>/dev/null; }; then
		herdr-last-tab daemon
	fi
fi

# herdr-notify: command-finished notifications (hook symlinked by the plugin)
if [[ -n "${HERDR_PANE_ID:-}" ]]; then
	local _notify_hook="${XDG_STATE_HOME:-$HOME/.local/state}/herdr-notify/hook.zsh"
	[[ -f "$_notify_hook" ]] && source "$_notify_hook"
fi
