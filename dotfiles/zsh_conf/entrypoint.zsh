# ---------------------------
# Install and load zinit (must be in .zshrc, zinit adding it if it doesn't)
# ---------------------------
### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
# ---------------------------

# ---------------------------
# Source the actual .zshrc files
# ---------------------------
source $HOME/.zsh_conf/aliases.zsh
source $HOME/.zsh_conf/settings.zsh
source $HOME/.zsh_conf/design.zsh
source $HOME/.zsh_conf/plugins.zsh
source $HOME/.zsh_conf/hooks.zsh

# Typer (must be in .zshrc, typer adding it if it doesn't)
autoload -Uz compinit
zstyle ':completion:*' menu select
fpath+=~/.zfunc
compinit # Build completions

# ---------------------------
# Source post_init.zsh at the end
# ---------------------------
source $HOME/.zsh_conf/post_init.zsh

### Added by broot
source /home/ofirg/.config/broot/launcher/bash/br
