# kv completions
if command -v kv &> /dev/null; then
	kv completions zsh > $ZSH_CACHE_DIR/completions/_kv
fi

cached_completion kv "kv completions zsh"
