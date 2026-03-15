#!/usr/bin/env sh

get_cwd() {
    pwd
}

get_git_branch() {
    git rev-parse --abbrev-ref HEAD 2>/dev/null || echo ""
}

get_git_repo() {
    basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo ""
}

get_tmux_session() {
    tmux display-message -p "#S" 2>/dev/null || echo ""
}

notify() {
    local msg="TMUX: $(get_tmux_session)\nREPO: $(get_git_repo)"
    notify-send "❇️ Claude $1 ❇️" "$msg"
}
