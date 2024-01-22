# ---------------------------
#			Misc
# ---------------------------
# Extra utils not in dotfiles
if test -f $HOME/.extra_utils; then
	source $HOME/.extra_utils
fi

# ---------------------------
#		  Daemons
# ---------------------------
if ! $IS_REMOTE; then
	if ! $WSL; then
		if ! pgrep fusuma > /dev/null;
		then
			fusuma --daemon
		fi
	fi
fi

# TODO: export to a plugin
# ---------------------------
#		  Auto tmux
# ---------------------------
if ! [ -z "$VIEW_TMUX_SESSION" ]; then # tmux-go
	echo "Creating viewer for $VIEW_TMUX_SESSION"
	# TODO: integrate with select_tmux_session
	if tmux ls | grep "$VIEW_TMUX_SESSION-viewer"; then
		# If for some reason there is a viewer session attach to it
		tmux attach -t "$VIEW_TMUX_SESSION-viewer"
	else
		# Create new viewer session
		tmux new-session -s "$VIEW_TMUX_SESSION-viewer" -t "$VIEW_TMUX_SESSION"
	fi

fi

export ZSH_TMUX_ALWAYS_SELECT_SESSION=true
select_tmux_session.sh
