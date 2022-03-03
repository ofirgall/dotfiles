# ---------------------------
# remote & sudo stuff
# ---------------------------
# Check if remote
IS_REMOTE=false
if test -f "$HOME/.remote_indicator"; then
	IS_REMOTE=true
fi

# Check if sudo
NO_SUDO=false
if test -f "$HOME/.no_sudo_indicator"; then
	NO_SUDO=true
fi

# Export Local pkgs if on remote (non-root usage)
if $NO_SUDO; then
	export PATH="$HOME/pkgs/usr/sbin:$HOME/pkgs/usr/bin:$HOME/pkgs/bin:$PATH"
	export MANPATH="$HOME/pkgs/usr/share/man:$MANPATH"

	L='/lib:/lib64:/usr/lib:/usr/lib64'
	export LD_LIBRARY_PATH="$HOME/pkgs/usr/lib:$HOME/pkgs/usr/lib64:$L"
	[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi

# ---------------------------
# Env vars
# ---------------------------
export PATH=~/.local/bin:~/dotfiles_scripts:$PATH
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export EDITOR='vim'
if type nvim &> /dev/null; then
	alias vim='nvim'
	alias vi='nvim'
	alias rvim='/usr/bin/vim'
	export EDITOR='nvim'
fi
