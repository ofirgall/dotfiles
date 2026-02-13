
# Check if remote
export IS_REMOTE=false
if test -f "$HOME/.remote_indicator"; then
	export IS_REMOTE=true
fi

# Check if sudo
export NO_SUDO=false
if test -f "$HOME/.no_sudo_indicator"; then
	export NO_SUDO=true
fi

# Check if WSL
export WSL=false
if [[ $(uname -a) == *"Microsoft"* ]]; then
	export WSL=true
fi

# Export Local pkgs if on remote (non-root usage)
if $NO_SUDO; then
	export PATH="$HOME/pkgs/usr/sbin:$HOME/pkgs/usr/bin:$HOME/pkgs/bin:$PATH"
	export MANPATH="$HOME/pkgs/usr/share/man:$MANPATH"

	L='/lib:/lib64:/usr/lib:/usr/lib64'
	export LD_LIBRARY_PATH="$HOME/pkgs/usr/lib:$HOME/pkgs/usr/lib64:$L"
	[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi

# GOLANG
export GOROOT=/usr/local/go
export GOPATH=~/go/
export CGO_ENABLED=0
export GOPRIVATE="bitbucket.org/volumez/*"
export PATH=$PATH:$GOPATH/bin
export PATH=$GOROOT/bin:$PATH

# Rust
export CARGO_NET_GIT_FETCH_WITH_CLI=true # fetch git dependecies

# Mason
export PATH=$HOME/.local/share/nvim/mason/bin:$PATH

# Volumez
export PATH=$PATH:$HOME/go/volumez-tools/tools

# Editor settings
export EDITOR='vim'
if type nvim &> /dev/null; then
	alias vi='vim'
	export EDITOR='nvim'

	# nvim as man viewer
	export MANPAGER='nvim +Man!'
	export MANWIDTH=999
fi

# Path
export PATH=~/dotfiles_scripts/notify:$PATH
export PATH=$PATH:~/dotfiles_scripts/misc
export PATH=$PATH:~/dotfiles_scripts/inner
export PATH=$PATH:~/dotfiles_scripts/git
export PATH=$PATH:~/dotfiles_scripts/tmux_layouts/
export PATH=$PATH:~/dotfiles_scripts/settings/
export PATH=$PATH:~/dotfiles_scripts/tmux/
export PATH=$PATH:$HOME/.spicetify

# Fix WAYLAND_DISPLAY pointing to wayland-0 when only wayland-1 exist
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
	if [ -S "/run/user/$UID/wayland-0" ]; then
		export WAYLAND_DISPLAY=wayland-0
	else
		for sock in /run/user/$UID/wayland-*; do
			[ -S "$sock" ] || continue
			export WAYLAND_DISPLAY=$(basename "$sock")
			break
		done
	fi
fi

# pnpm
export PNPM_HOME="/home/ofirg/.local/share/pnpm"
case ":$PATH:" in
	*":$PNPM_HOME:"*) ;;
	*) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# AWS
export AWS_PROFILE=dev

source $HOME/secrets.zsh

export PATH=~/dotfiles_scripts/wrappers:$PATH
