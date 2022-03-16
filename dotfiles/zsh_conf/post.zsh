
# ---------------------------
#		Local Settings
# ---------------------------
if ! $IS_REMOTE; then
	. "$HOME/.cargo/env" # Rust

	xmodmap ~/.xmodmaprc 2> /dev/null # key mapping, xev to see keys
	xset r rate 200 35 # Faster repeat rate
fi

# ---------------------------
#			Misc
# ---------------------------
# Load wslrc
if [[ $(uname -a) == *"WSL"* ]]; then
	source ~/.wslrc
fi

# Extra utils not in dotfiles
if test -f $HOME/.extra_utils; then
	source $HOME/.extra_utils
fi

# ---------------------------
#		  Daemons
# ---------------------------
if ! $IS_REMOTE; then
	if ! pgrep fusuma > /dev/null;
	then
		fusuma --daemon
	fi

	if ! pgrep autokey-gtk > /dev/null;
	then
		daemon --name="autokey" autokey-gtk
	fi
fi

# ---------------------------
#		  Auto tmux
# ---------------------------
export ZSH_TMUX_ALWAYS_SELECT_SESSION=true
if ! $IS_REMOTE; then
	$HOME/.tmux/tmux-go/src/tmux_go_attach.sh
fi

if [ ! -z $ATTACH_TO ]; then # Attach on remote (smux)
	tmux attach -t $ATTACH_TO
fi
select_tmux_session.sh
