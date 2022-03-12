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

# ---------------------------
#		   Aliases
# ---------------------------
alias pwdc='echo \"$(pwd)\" | tr -d "\n" | toclip'
alias pwdcd='echo "cd \"$(pwd)\"" | toclip'
alias sublp='subl *.sublime-project'
alias open='xdg-open'
alias venv='. ~/venv3/bin/activate'
alias notify='notify-send -u critical -t 3000 done'
alias notify-send='notify-send.sh -f'
alias get_ticket='git rev-parse --abbrev-ref HEAD | grep -oP ".+/\K([A-Z]+-[0-9]+)" | tr -d "\n"'
alias cticket='get_ticket | toclip'
alias ticket='xdg-open https://jira.infinidat.com/browse/$(get_ticket)'
alias cbranch='git rev-parse --abbrev-ref HEAD | tr -d "\n" | toclip'
alias tkill='tmux kill-session'
alias trename='tmux rename-session'
alias taskopen-fzf='taskopen -l | sed "s/ *[0-9]*) //" | sed "/^$/d" | fzf | sed "s/.*-- \([0-9]*\)/\1/" | sponge | { IFS= read -r x; { printf "%s\n" "$x"; cat; } | xargs taskopen }'
function cg() { cd $(inner_cg.sh $@) } # cd to git repos
function smux() # SSH TMUX (sending current session over LC_MESSAGES (allowed in /etc/ssh/ssh_config))
{
	LC_MESSAGES=$(tmux display-message -p '#S') ssh -o SendEnv=LC_MESSAGES $1
}

# Git aliases, no git plugin
alias g='git'
alias ga='git add'
alias gc='git commit'
alias gcam='git commit -a -m'
alias gco='git checkout'
alias gd='git diff'
alias gf='git fetch'
alias gl='git pull'
alias gp='git push'
alias gst='git status'
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'
alias gh='git hist'
alias gdiff='git diff'
alias gshow='git show'

# Remote/Local Aliases
if $IS_REMOTE; then
	alias toclip='~/dotfiles_scripts/osc52_yank.sh'
else
	alias toclip='xclip -sel clip'
fi