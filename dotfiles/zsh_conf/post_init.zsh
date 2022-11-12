
# ---------------------------
#	Settings that takes time
# ---------------------------
if ! $IS_REMOTE; then
	. "$HOME/.cargo/env" # Rust

	if ! $WSL; then
		xmodmap ~/.xmodmaprc 2> /dev/null # key mapping, xev to see keys
	fi
fi

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

# ---------------------------
#		  Auto tmux
# ---------------------------
export ZSH_TMUX_ALWAYS_SELECT_SESSION=true
if ! $IS_REMOTE && ! $WSL; then
	$HOME/.tmux/tmux-go/src/tmux_go_attach.sh
fi

if [ ! -z $ATTACH_TO ]; then # Attach on remote (smux)
	tmux attach -t $ATTACH_TO
fi
select_tmux_session.sh
