# ---------------------------
#		  ofirgall/cd-to-git
# ---------------------------
export CD_TO_GIT_DEFAULT_DIR=~/workspace/work/

# ---------------------------
#		zsh-auto-notify
# ---------------------------
export AUTO_NOTIFY_THRESHOLD=600 # 10 minutes
export AUTO_NOTIFY_IGNORE=("docker" "man" "sleep" "nvim" "nvlog" "./envctl.py" "pg" "python" "python3" "python2" "viewer" "lsj" "ssh" "rssh" "assh" "gshow" "nv" "v" "kv" "less" "ipython" "c" "gt" "gd" "ai" "mdp")

# ---------------------------
#		  zsh-vi-mode
# ---------------------------
# MSYS2 zsh regex engine can't compile the escape sequences in zvm_cursor_style
if [[ -n "$MSYSTEM" ]]; then
	export ZVM_CURSOR_STYLE_ENABLED=false
fi

