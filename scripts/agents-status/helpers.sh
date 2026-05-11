#!/usr/bin/env sh
# Sourced by claude / cursor hook scripts.

AGENTS_STATUS_DIR="${AGENTS_STATUS_DIR:-$HOME/dotfiles_scripts/agents-status}"

# Populates TMUX_SESSION, TMUX_WINDOW_ID, TMUX_WINDOW_INDEX in one tmux call.
# Empty if not inside tmux. Cached across calls within the same process.
_load_tmux_info() {
    [ -n "$_TMUX_INFO_LOADED" ] && return
    _TMUX_INFO_LOADED=1
    TMUX_SESSION=""
    TMUX_WINDOW_ID=""
    TMUX_WINDOW_INDEX=""
    [ -n "$TMUX" ] && [ -n "$TMUX_PANE" ] && command -v tmux >/dev/null 2>&1 || return
    local info
    info="$(tmux display-message -p -t "$TMUX_PANE" \
        '#{session_name}	#{window_id}	#{window_index}' 2>/dev/null)" || return
    TMUX_SESSION="${info%%	*}"
    info="${info#*	}"
    TMUX_WINDOW_ID="${info%%	*}"
    TMUX_WINDOW_INDEX="${info#*	}"
}

get_instance_id() {
    _load_tmux_info
    if [ -n "$TMUX_SESSION" ] && [ -n "$TMUX_WINDOW_ID" ]; then
        printf 'tmux:%s:%s' "$TMUX_SESSION" "$TMUX_WINDOW_ID"
        return
    fi
    local t
    t="$(tty 2>/dev/null)"
    if [ -n "$t" ] && [ "$t" != "not a tty" ]; then
        printf 'tty:%s' "$t"
        return
    fi
    printf 'pid:%s' "$PPID"
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

# Latest ai-title from a Claude transcript JSONL. Empty if not yet generated.
_get_claude_title() {
    [ -n "$CLAUDE_TRANSCRIPT_PATH" ] && [ -f "$CLAUDE_TRANSCRIPT_PATH" ] || return
    tac "$CLAUDE_TRANSCRIPT_PATH" 2>/dev/null \
        | grep -a -m1 '"type":"ai-title"' \
        | python3 -c 'import json,sys
try:
    t = json.loads(sys.stdin.read()).get("aiTitle", "")
    print(t if len(t) <= 25 else t[:24].rstrip() + "…")
except Exception:
    pass' 2>/dev/null
}

# send_event AGENT STATUS [NOTIFY] [CLEAR] [UNSET_STATUS]
# Set AGENTS_STATUS_DEFER=1 in the environment to mark the event as deferred:
# the server holds it briefly and drops it if any follow-up event arrives for
# the same instance. Used to suppress cursor's "Requires Permission" event
# when auto-run kicks in (afterShellExecution arrives shortly after).
send_event() {
    local agent="$1" status="$2" notify="$3" clear="$4" unset_status="$5"
    local iid repo branch title payload defer="${AGENTS_STATUS_DEFER:-}"
    iid="$(get_instance_id)"
    _load_tmux_info
    repo="$(_get_repo)"
    branch="$(_get_branch)"
    if [ "$agent" = "claude" ]; then
        title="$(_get_claude_title)"
    fi

    payload="$(python3 - "$agent" "$iid" "$status" "$notify" "$clear" \
        "$TMUX_SESSION" "$TMUX_WINDOW_INDEX" "$repo" "$branch" "$unset_status" "$defer" "$title" <<'PY'
import json, sys
(agent, iid, status, notify, clear,
 tmux_sess, tmux_win, repo, branch, unset_status, defer, title) = sys.argv[1:13]
ev = {"agent": agent, "instance_id": iid}
if status:        ev["status"] = status
if notify:        ev["notify"] = notify
if clear:         ev["clear"] = True
if unset_status:  ev["unset_status"] = True
if tmux_sess:     ev["tmux_session"] = tmux_sess
if tmux_win:      ev["tmux_window"] = tmux_win
if repo:          ev["repo"] = repo
if branch:        ev["branch"] = branch
if defer:         ev["defer"] = True
if title:         ev["tmux_title"] = title
print(json.dumps(ev))
PY
)"

    "$AGENTS_STATUS_DIR/send" "$payload"
}

ensure_server() {
    "$AGENTS_STATUS_DIR/ensure-running"
}
