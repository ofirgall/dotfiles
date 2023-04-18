# ---------------------------
#		  Plugins
# ---------------------------
source $HOME/.zsh_conf/plugin_settings.zsh
## oh-my-zsh plugins ##
zinit ice wait lucid
zinit snippet OMZP::pip

zinit ice wait lucid
zinit snippet OMZP::sudo

zinit ice wait lucid
zinit snippet OMZP::tmux

zinit ice wait lucid
zinit snippet OMZP::rust

zinit ice svn
zinit snippet OMZP::gitfast

## Custom Plugins ##
if [[ ${ZSH_VERSION:0:3} -ge 5.1 ]]; then
	zinit ice depth=1
	zinit light jeffreytse/zsh-vi-mode
fi

zinit ice wait lucid atload'_zsh_autosuggest_start; bindkey "^ " autosuggest-accept'
zinit light zsh-users/zsh-autosuggestions

if [[ ${ZSH_VERSION:0:3} -ge 5.8 ]]; then
	zinit ice wait lucid
	zinit light Aloxaf/fzf-tab
fi

zinit ice wait lucid
zinit light ofirgall/cd-to-git

zinit ice wait lucid
zinit light paulirish/git-open

zinit ice wait lucid
zinit light peterhurford/up.zsh

zinit ice wait lucid
zinit light joshskidmore/zsh-fzf-history-search

if [[ ${ZSH_VERSION:0:3} -ge 5.1 ]] && ! $WSL; then
	zinit ice wait lucid
	zinit light larkery/zsh-histdb
fi

# zsh-completions
zinit wait lucid atload"zicompinit; zicdreplay" blockf for \
    zsh-users/zsh-completions

zinit ice wait lucid
zinit light hlissner/zsh-autopair

if ! $IS_REMOTE; then
	zinit ice wait lucid
	zinit light MichaelAquilina/zsh-auto-notify
fi
