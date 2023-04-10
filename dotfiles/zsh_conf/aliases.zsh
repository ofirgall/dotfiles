# ---------------------------
#		   Aliases
# ---------------------------
function nv() {
	while true
	do
		nvim $@
		if ! test -f /tmp/restart_nvim; then
			break
		fi
		rm /tmp/restart_nvim
	done
}
alias nv='v'
alias br='broot --conf ~/.brootrc.toml'
alias lz='XDG_CONFIG_HOME=~/dotfiles_wip/editors/lazynvim/ XDG_DATA_HOME=~/.local/share/wip_nvim XDG_STATE_HOME=~/.local/state/wip_nvim nvim'
alias lzlog='XDG_CONFIG_HOME=~/dotfiles_wip/editors/lazynvim/ XDG_DATA_HOME=~/.local/share/wip_nvim XDG_STATE_HOME=~/.local/state/wip_nvim NVLOG=1 nvim'
alias cat='bat'
alias pwdc='echo \"$(pwd)\" | tr -d "\n" | toclip'
alias pwdcd='echo "cd \"$(pwd)\"" | toclip'
alias sublp='subl *.sublime-project'
alias open='xdg-open'
alias venv='. ~/venv3/bin/activate'
alias notify='notify-send -u critical done'
# alias get_ticket='git rev-parse --abbrev-ref HEAD | grep -oP ".+/\K([A-Z]+-[0-9]+)" | tr -d "\n"'
function get_ticket() {
	local branch=$(git rev-parse --abbrev-ref HEAD 2>&1 | tr -d "\n")
	if echo $branch | grep -q "fatal"; then
		# non git folder, try to from pwd
		echo "$PWD" | grep -oP "([A-Z]+-[0-9]+)"
	else
		echo $branch | grep -oP ".+/\K([A-Z]+-[0-9]+)"
	fi
}
alias cticket='get_ticket | toclip'
alias ticket='xdg-open https://volumez.atlassian.net/browse/$(get_ticket)'
alias cbranch='git rev-parse --abbrev-ref HEAD | tr -d "\n" | toclip'
alias tkill='tmux kill-session'
alias trename='tmux rename-session'
alias todo='nvim ~/todo.norg'
alias taskopen-fzf='taskopen -l | sed "s/ *[0-9]*) //" | sed "/^$/d" | fzf | sed "s/.*-- \([0-9]*\)/\1/" | sponge | { IFS= read -r x; { printf "%s\n" "$x"; cat; } | xargs taskopen }'
alias cdl='cd "$_"' # cd to last arg (usefull after mkdir)
alias cdd='cd $HOME/dotfiles'
alias cgp='cg $HOME/workspace/personal/' # cg to packer/plugins
alias cdn='cd $HOME/dotfiles/editors/nvim/' # cd to neovim config
alias cdz='cd $HOME/dotfiles/dotfiles/zsh_conf/' # cd to zhs config
alias cdp='cd $HOME/.local/share/nvim/site/pack/packer/start' # cd to packer/plugins
alias cgnp='cg $HOME/.local/share/nvim/site/pack/packer/start' # cg to packer/plugins
alias cdt='cd $HOME/.local/share/nvim/site/pack/packer/start/ofirkai.nvim/' # cd to nvim theme
alias cda='cd $HOME/.config/awesome/' # cd to awesome config
alias cgt='cg $HOME/.tmux/plugins/' # cg to tmux plugins
alias g='fugitive' # git fugitive
alias ngh='git_tree' # git history with nvim and Flog
function cg() { cd $(inner_cg.sh $@) } # cd to git repos
alias cgg='cg ~/go' # cg to go
alias cgk='cg ~/workspace/kernels/' # cg to kernels
function p() { python -c "print($@)"} # run python easily
function ssh() {
	TERM=xterm-256color /usr/bin/ssh $@ # Adjust TERM for ssh
}
alias cls='tmux clear-history; clear'
alias drop_cache='sync; echo 1 | sudo tee /proc/sys/vm/drop_caches'
alias pg='cg $HOME/playgrounds && nv' # cd to packer/plugins
function tmp() {
	neovim=nv
	if [ "$1" = "log" ]; then
		neovim=nvlog
	fi
	SCRATCH_FILE=$(mktemp -t scratch.XXXX); $neovim $SCRATCH_FILE +"set ft=$1"; echo $SCRATCH_FILE
}
function nvlog() {
	NVLOG=1 nv $@
}
function logs() {
	ticket=$(get_ticket)
	if ! test -d ~/logs/$ticket; then
		mkdir -p ~/logs/$ticket
	fi
	cd ~/logs/$ticket
}

# System settings
alias wifi='nmtui'
alias audio='pavucontrol'
alias sound='pavucontrol'

# Volumez
alias capi='./envctl.py state | grep api | grep -o "http.*\"" | sed -s "s/\"//" | toclip' # Copy API url
alias csio='cat envctl_state.json | jq -r ".envs.env.sio.public_dns" | toclip'
alias db='cat envctl_state.json | jq -r ".envs.env.sio.public_dns" | xargs printf "http://%s:8002" | xargs open'
alias lsj='lsjobs'

# Git aliases, no git plugin
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
