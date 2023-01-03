# ---------------------------
#		   Aliases
# ---------------------------
alias nv='nvim'
alias cat='bat'
alias pwdc='echo \"$(pwd)\" | tr -d "\n" | toclip'
alias pwdcd='echo "cd \"$(pwd)\"" | toclip'
alias sublp='subl *.sublime-project'
alias open='xdg-open'
alias venv='. ~/venv3/bin/activate'
alias notify='notify-send -u critical done'
alias get_ticket='git rev-parse --abbrev-ref HEAD | grep -oP ".+/\K([A-Z]+-[0-9]+)" | tr -d "\n"'
alias cticket='get_ticket | toclip'
alias ticket='xdg-open https://jira.infinidat.com/browse/$(get_ticket)'
alias cbranch='git rev-parse --abbrev-ref HEAD | tr -d "\n" | toclip'
alias tkill='tmux kill-session'
alias trename='tmux rename-session'
alias todo='nvim ~/todo.norg'
alias taskopen-fzf='taskopen -l | sed "s/ *[0-9]*) //" | sed "/^$/d" | fzf | sed "s/.*-- \([0-9]*\)/\1/" | sponge | { IFS= read -r x; { printf "%s\n" "$x"; cat; } | xargs taskopen }'
alias cdd='cd $HOME/dotfiles'
alias cdn='cd $HOME/dotfiles/editors/nvim/' # cd to neovim config
alias cdp='cd $HOME/.local/share/nvim/site/pack/packer/start' # cd to packer/plugins
alias cgp='cg $HOME/.local/share/nvim/site/pack/packer/start' # cg to packer/plugins
alias cdt='cd $HOME/.local/share/nvim/site/pack/packer/start/ofirkai.nvim/' # cd to nvim theme
alias cda='cd $HOME/.config/awesome/' # cd to awesome config
alias cgt='cg $HOME/.tmux/plugins/' # cg to tmux plugins
alias g='fugitive' # git fugitive
alias ngh='git_tree' # git history with nvim and Flog
function cg() { cd $(inner_cg.sh $@) } # cd to git repos
alias cgg='cg ~/go' # cg to go
function p() { python -c "print($@)"} # run python easily
function ssh() {
	TERM=xterm-256color /usr/bin/ssh $@ # Adjust TERM for ssh
}
alias cls='tmux clear-history; clear'
alias pg='cg $HOME/playgrounds && nv' # cd to packer/plugins
function tmp() {
	SCRATCH_FILE=$(mktemp -t scratch.XXXX); nv $SCRATCH_FILE +"set ft=$1"; echo $SCRATCH_FILE
}
function nvlog() {
	NVLOG=1 nv $@
}

# System settings
alias wifi='nmtui'
alias audio='pavucontrol'
alias sound='pavucontrol'

# Volumez
alias capi='./envctl.py state | grep api | grep -o "http.*\"" | sed -s "s/\"//" | toclip' # Copy API url
alias csio='cat envctl_state.json | jq -r ".envs.env.sio.public_dns" | toclip'
alias db='cat envctl_state.json | jq -r ".envs.env.sio.public_dns" | xargs printf "http://%s:8002" | xargs open'

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
