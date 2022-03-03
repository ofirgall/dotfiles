
# ---------------------------
#		   Aliases
# ---------------------------
alias ll='ls -alF'
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

# ---------------------------
#		   Binds
# ---------------------------
bindkey -M main "^ " autosuggest-accept # Ctrl+Space
bindkey -M vicmd "^ " autosuggest-accept # Ctrl+Space
bindkey "^ " autosuggest-accept # Ctrl+Space
