
alias nv=kv
alias nv-10='kv --override-state --profile 010 --nvim-bin-path ~/.local/nvim-010/bin/bin/nvim --lua-cfg ~/dotfiles/editors/KoalaConfig-10/'
alias v=kv
alias br='broot --conf ~/.brootrc.toml'
alias lz='XDG_CONFIG_HOME=~/dotfiles_wip/editors/lazynvim/ XDG_DATA_HOME=~/.local/share/wip_nvim XDG_STATE_HOME=~/.local/state/wip_nvim nvim'
alias lzlog='XDG_CONFIG_HOME=~/dotfiles_wip/editors/lazynvim/ XDG_DATA_HOME=~/.local/share/wip_nvim XDG_STATE_HOME=~/.local/state/wip_nvim NVLOG=1 nvim'
alias cat='bat'
alias btmf='btm -C "$HOME/dotfiles/dotfiles/bottom/bottom-full.toml"'
alias open-codex-plan='codex-latest-plan.sh | mdp --full'
alias del='ez session delete'
alias new='ez session new'
alias t='select_tmux_session.sh'

if [[ "$(uname)" == "Darwin" ]]; then
	:
elif [[ -n "$MSYSTEM" ]]; then
	alias open='start'
else
	alias open='xdg-open'
fi
alias venv='. ./bin/activate'
alias notify='notify-send -u critical done'

# cd aliases
alias cdd='cd $HOME/dotfiles' # cd to dotfiles
alias cdn='cd $HOME/dotfiles/editors/KoalaConfig/' # cd to neovim config
alias cdz='cd $HOME/.my-zsh-conf/' # cd to personal zsh config
alias cdZ='cd $HOME/.zsh-conf/' # cd to zsh config
alias cdt='cd $HOME/dotfiles/dotfiles/tmux_conf/' # cd to tmux config
alias cdnt='cd $HOME/.local/share/nvim/lazy/ofirkai.nvim/' # cd to nvim theme
alias cda='cd $HOME/.config/awesome/' # cd to awesome config
cdw() {
	if [[ "$(tmux show-options -v -t "$TMUX_PANE" @ez_managed 2>/dev/null)" == "1" ]]; then
		ez cd-to-session
	else
		cd "$HOME/worktrees/$(tmux display-message -p "#S" | sed "s,-,/,")" # cd to my worktree tmux standard
	fi
}
alias cdh='cd $HOME/dotfiles/hypr-dots/' # cd to hypr-dots
alias cdr='groot'
alias gr='groot'
alias plans='cd ~/.cursor/plans' # cd cursor plans

# cg aliases
alias cgp='cg $HOME/workspace/personal/' # cg to personal
alias cgw='cg $HOME/worktrees/'
alias cgnp='cg $HOME/.local/share/kvim-envs/${KV_ENV:-main}/lazy/'
cgk() {
  local dir
  dir=$(ls -d "$HOME/.local/share/kvim-envs"/*/ 2>/dev/null | xargs -n1 basename | fzf --reverse --height=30) || return
  cg "$HOME/.local/share/kvim-envs/$dir/lazy/"
}
alias cgzp='cg $HOME/.local/share/zinit/plugins/' # cg to zsh plugins
alias cgt='cg $HOME/.tmux/plugins/' # cg to tmux plugins
alias cgg='cg $HOME/go' # cg to go
alias cgK='cg $HOME/workspace/kernels/' # cg to kernels

# ez aliases
alias ezp='ez --workspace $HOME/workspace/personal/'
alias ezw='ez --workspace $HOME/workspace/work/'

# Misc
alias taskopen-fzf='taskopen -l | sed "s/ *[0-9]*) //" | sed "/^$/d" | fzf | sed "s/.*-- \([0-9]*\)/\1/" | sponge | { IFS= read -r x; { printf "%s\n" "$x"; cat; } | xargs taskopen }'

function ai() {
	# git fugitive
	kv --ai -- $@
}

# Git
function g() {
	# git fugitive
	kv --git -- $@
}
function gt() {
	kv --tree -- $@
}
unalias gd # Remove ofir zsh framework ghs
function gd() {
	kv --git-diff -- $@
}
function gdm() {
	kv --git-diff -- $(git merge-base HEAD origin/main)
}
unalias ghs # Remove ofir zsh framework ghs
alias ghs='gt'

alias gshowp='git show-patch'
alias cb='cbranch'

# GitHub
alias gpc="gh pr create"
alias gpv="gh pr view --web"
alias gpvc="gh pr view | egrep \"url:\" | head -n 1 | sed \"s/url://g\" | xargs echo -n | toclip"
alias gpar="gh pr edit --add-reviewer"
alias ghd="gh dash"
alias mdp="gh markdown-preview --full"

function gh_select_account() {
	local users=("${(@f)$(gh auth status 2>/dev/null | awk '/Logged in/ {for(i=1;i<=NF;i++) if($i=="account") print $(i+1)}')}")
	(( ${#users[@]} <= 1 )) && return 0
	local selected
	selected="$(printf '%s\n' "${users[@]}" | fzf --prompt='GitHub account> ' --height=40% --reverse)"
	[[ -z "$selected" ]] && { echo "No selection"; return 1 }
	gh auth switch -u "$selected"
}

function gfork() {
	local prev_user="$(gh api user --jq .login 2>/dev/null)"

	gh_select_account || return 1

	git remote rename origin upstream
	gh repo fork --remote --remote-name origin

	# Set default to new origin
	local branch="$(git branch --show-current)"
	git config remote.pushDefault origin
	git push --set-upstream origin $branch
	git branch --set-upstream-to="origin/$branch"
	git config branch.$branch.pushremote origin

	[[ -n "$prev_user" ]] && gh auth switch -u "$prev_user"
}

function ssh() {
	TERM=xterm-256color /usr/bin/ssh $@ # Adjust TERM for ssh
}

alias cls='tmux clear-history; clear'
alias pg='cg $HOME/playgrounds && nv' # cd to packer/plugins

function tmp() {
	neovim=kv
	SCRATCH_FILE=$(mktemp -t scratch.XXXX); $neovim $SCRATCH_FILE +"set ft=$1"; echo $SCRATCH_FILE
}
function nvlog() {
	NVLOG=1 nv $@
}

# System settings
alias wifi='nmtui'
alias audio='pavucontrol'
alias sound='pavucontrol'
alias lock='systemctl --user start autolock'
alias unlock='systemctl --user stop autolock'

# Tools
alias demo='simplescreenrecorder'

# Volumez
export VREC_ENV_NAME=ofir
alias capi='cat envctl_state.json | jq -r ".envs.$VREC_ENV_NAME.api_gw_invoke_url" | toclip' # Copy API url
alias csio='cat envctl_state.json | jq -r ".envs.$VREC_ENV_NAME.sio.public_dns" | toclip'
alias db='cat envctl_state.json | jq -r ".envs.$VREC_ENV_NAME.sio.public_dns" | xargs printf "http://%s:8002" | xargs open'
alias lsj='lsjobs'
alias ectl='cd ~/go/volumez/automation/envctl/'

# Create notes dir & cd for the current tmux session
function notes() {
	local session=$(tmux display-message -p "#S" | sed "s,-,/,g")
	if ! test -d ~/notes/$session; then
		mkdir -p ~/notes/$session
	fi
	cd ~/notes/$session
}

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# set ez() function
eval "$(ez init-shell zsh)"

alias c=y

drift-mcp-auth() {
  local projects_dir="$HOME/.cursor/projects"
  local src_path="$HOME/workspace/work/drift"
  local src_slug=$(echo "$src_path" | sed -E 's/[^a-zA-Z0-9]/-/g; s/-+/-/g; s/^-+|-+$//g')
  local src="$projects_dir/$src_slug/mcp-auth.json"

  if [[ ! -f "$src" ]]; then
    echo "Source mcp-auth.json not found: $src" >&2
    return 1
  fi

  local slug=$(pwd | sed -E 's/[^a-zA-Z0-9]/-/g; s/-+/-/g; s/^-+|-+$//g')
  local dest_dir="$projects_dir/$slug"
  local dest="$dest_dir/mcp-auth.json"

  mkdir -p "$dest_dir"
  ln -sf "$src" "$dest"
  echo "Linked mcp-auth.json -> $dest"
}
