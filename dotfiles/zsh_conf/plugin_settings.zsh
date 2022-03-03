
# ---------------------------
#		  OMZ:tmux
# ---------------------------
ZSH_TMUX_AUTOSTART=false
ZSH_TMUX_AUTOSTART_ONCE=false
ZSH_TMUX_AUTOQUIT=false
ZSH_TMUX_FIXTERM=false

# ---------------------------
#		  FZF Tab
# ---------------------------
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# preview directory's content with exa when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath'
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'

# ---------------------------
#		  FZF History
# ---------------------------
ZSH_FZF_HISTORY_SEARCH_FZF_EXTRA_ARGS='--height=10 --reverse'
