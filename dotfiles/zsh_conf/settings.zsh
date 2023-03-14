# ---------------------------
# Basic ZSH Settings from oh-my-zsh
# ---------------------------

# Functions cant be turbo and must be first
zinit snippet OMZL::functions.zsh
# Can't be turbo for history plugins (autosuggestions)
zinit snippet OMZL::history.zsh

# Can't turbo key-bindings, conflicting with vim-mode
zinit snippet OMZL::key-bindings.zsh

zinit ice wait lucid
zinit snippet OMZL::theme-and-appearance.zsh

zinit ice wait lucid
zinit snippet OMZL::completion.zsh

zinit ice wait lucid
zinit snippet OMZL::correction.zsh

# Not lucid to override alias later
zinit snippet OMZL::directories.zsh
# Override ll of oh-my-zsh
alias ll='ls -alF'
alias l='ls -alF'

zinit ice wait lucid
zinit snippet OMZL::grep.zsh

zinit ice wait lucid
zinit snippet OMZL::misc.zsh

