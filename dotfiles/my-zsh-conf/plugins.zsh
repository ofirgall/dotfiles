# if ! $IS_REMOTE; then
# 	zinit ice wait lucid
# 	zinit light MichaelAquilina/zsh-auto-notify
# fi

# zsh-vi-mode: regex in zvm_cursor_style breaks on MSYS2 zsh
if [[ -n "$MSYSTEM" ]] && (( ${+functions[zvm_cursor_style]} )); then
	zvm_cursor_style() { echo -n '\e[0 q'; }
fi
