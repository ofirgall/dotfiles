#!/usr/bin/env sh
# Sourced by claude / cursor hook scripts.

AGENTS_STATUS_DIR="${AGENTS_STATUS_DIR:-$HOME/dotfiles_scripts/agents-status}"

get_instance_id() {
    if [ -n "$TMUX" ] && [ -n "$TMUX_PANE" ] && command -v tmux >/dev/null 2>&1; then
        local sess win
        sess="$(tmux display-message -p -t "$TMUX_PANE" '#{session_name}' 2>/dev/null)"
        win="$(tmux display-message -p -t "$TMUX_PANE" '#{window_id}' 2>/dev/null)"
        if [ -n "$sess" ] && [ -n "$win" ]; then
            printf 'tmux:%s:%s' "$sess" "$win"
            return
        fi
    fi
    local t
    t="$(tty 2>/dev/null)"
    if [ -n "$t" ] && [ "$t" != "not a tty" ]; then
        printf 'tty:%s' "$t"
        return
    fi
    printf 'pid:%s' "$PPID"
}

_get_tmux_session() {
    [ -n "$TMUX" ] && [ -n "$TMUX_PANE" ] && \
        tmux display-message -p -t "$TMUX_PANE" '#{session_name}' 2>/dev/null
}

_get_tmux_window_index() {
    [ -n "$TMUX" ] && [ -n "$TMUX_PANE" ] && \
        tmux display-message -p -t "$TMUX_PANE" '#{window_index}' 2>/dev/null
}

_project_dir() {
    # Prefer env vars set by agents; fall back to cwd.
    if [ -n "$CURSOR_PROJECT_DIR" ]; then
        printf '%s' "$CURSOR_PROJECT_DIR"
    elif [ -n "$CLAUDE_PROJECT_DIR" ]; then
        printf '%s' "$CLAUDE_PROJECT_DIR"
    else
        pwd
    fi
}

_get_repo() {
    local top
    top="$(git -C "$(_project_dir)" rev-parse --show-toplevel 2>/dev/null)"
    [ -n "$top" ] && basename "$top"
}

_get_branch() {
    git -C "$(_project_dir)" rev-parse --abbrev-ref HEAD 2>/dev/null
}

# send_event AGENT STATUS [NOTIFY] [CLEAR] [UNSET_STATUS]
send_event() {
    local agent="$1" status="$2" notify="$3" clear="$4" unset_status="$5"
    local iid tmux_sess tmux_win repo branch payload
    iid="$(get_instance_id)"
    tmux_sess="$(_get_tmux_session)"
    tmux_win="$(_get_tmux_window_index)"
    repo="$(_get_repo)"
    branch="$(_get_branch)"

    payload="$(python3 - "$agent" "$iid" "$status" "$notify" "$clear" \
        "$tmux_sess" "$tmux_win" "$repo" "$branch" "$unset_status" <<'PY'
import json, sys
(agent, iid, status, notify, clear,
 tmux_sess, tmux_win, repo, branch, unset_status) = sys.argv[1:11]
ev = {"agent": agent, "instance_id": iid}
if status:        ev["status"] = status
if notify:        ev["notify"] = notify
if clear:         ev["clear"] = True
if unset_status:  ev["unset_status"] = True
if tmux_sess:     ev["tmux_session"] = tmux_sess
if tmux_win:      ev["tmux_window"] = tmux_win
if repo:          ev["repo"] = repo
if branch:        ev["branch"] = branch
print(json.dumps(ev))
PY
)"

    "$AGENTS_STATUS_DIR/send" "$payload"
}

ensure_server() {
    "$AGENTS_STATUS_DIR/ensure-running"
}
