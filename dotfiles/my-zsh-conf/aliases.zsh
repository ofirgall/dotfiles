
function nv() {
	nvim $@
	while true
	do
		if ! test -f /tmp/restart_nvim; then
			break
		fi
		rm /tmp/restart_nvim
		KOALA_RESTART=1 nvim $@
	done
}
function v() {
	nv
}
alias br='broot --conf ~/.brootrc.toml'
alias lz='XDG_CONFIG_HOME=~/dotfiles_wip/editors/lazynvim/ XDG_DATA_HOME=~/.local/share/wip_nvim XDG_STATE_HOME=~/.local/state/wip_nvim nvim'
alias lzlog='XDG_CONFIG_HOME=~/dotfiles_wip/editors/lazynvim/ XDG_DATA_HOME=~/.local/share/wip_nvim XDG_STATE_HOME=~/.local/state/wip_nvim NVLOG=1 nvim'
alias cat='bat'

alias open='xdg-open'
alias venv='. ~/venv3/bin/activate'
alias notify='notify-send -u critical done'

# cd aliases
alias cdd='cd $HOME/dotfiles' # cd to dotfiles
alias cdn='cd $HOME/dotfiles/editors/KoalaConfig/' # cd to neovim config
alias cdz='cd $HOME/dotfiles/dotfiles/zsh_conf/' # cd to zsh config
alias cdt='cd $HOME/dotfiles/dotfiles/tmux_conf/' # cd to tmux config
alias cdnt='cd $HOME/.local/share/nvim/lazy/ofirkai.nvim/' # cd to nvim theme
alias cda='cd $HOME/.config/awesome/' # cd to awesome config
alias cdw='cd $HOME/worktrees/$(tmux display-message -p "#S" | sed "s,-,/,g")' # cd to my worktree tmux standard

# cg aliases
alias cgp='cg $HOME/workspace/personal/' # cg to personal
alias cgw='cg $HOME/worktrees/'
alias cgnp='cg $HOME/.local/share/nvim/lazy' # cg to nvim plugins
alias cgzp='cg $HOME/.local/share/zinit/plugins/' # cg to zsh plugins
alias cgt='cg $HOME/.tmux/plugins/' # cg to tmux plugins
alias cgg='cg $HOME/go' # cg to go
alias cgk='cg $HOME/workspace/kernels/' # cg to kernels

# Misc
alias taskopen-fzf='taskopen -l | sed "s/ *[0-9]*) //" | sed "/^$/d" | fzf | sed "s/.*-- \([0-9]*\)/\1/" | sponge | { IFS= read -r x; { printf "%s\n" "$x"; cat; } | xargs taskopen }'
alias g='fugitive' # git fugitive
alias ngh='git_tree' # git history with nvim and Flog

function ssh() {
	TERM=xterm-256color /usr/bin/ssh $@ # Adjust TERM for ssh
}

alias cls='tmux clear-history; clear'
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

# System settings
alias wifi='nmtui'
alias audio='pavucontrol'
alias sound='pavucontrol'

# Tools
alias demo='simplescreenrecorder'

# Volumez
alias capi='./envctl.py state | grep api | grep -o "http.*\"" | sed -s "s/\"//" | toclip' # Copy API url
alias csio='cat envctl_state.json | jq -r ".envs.env.sio.public_dns" | toclip'
alias db='cat envctl_state.json | jq -r ".envs.env.sio.public_dns" | xargs printf "http://%s:8002" | xargs open'
alias lsj='lsjobs'
alias ectl='cd ~/go/volumez/automation/envctl/'
