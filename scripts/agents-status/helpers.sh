#!/usr/bin/env sh
# Sourced by claude / cursor hook scripts.

AGENTS_STATUS_DIR="${AGENTS_STATUS_DIR:-$HOME/dotfiles_scripts/agents-status}"

get_instance_id() {
    if [ -n "$TMUX" ] && command -v tmux >/dev/null 2>&1; then
        local sess win
        sess="$(tmux display-message -p '#{session_name}' 2>/dev/null)"
        win="$(tmux display-message -p '#{window_id}' 2>/dev/null)"
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

# send_event AGENT STATUS [NOTIFY] [CLEAR]
send_event() {
    local agent="$1" status="$2" notify="$3" clear="$4"
    local iid payload
    iid="$(get_instance_id)"

    payload="$(python3 - "$agent" "$iid" "$status" "$notify" "$clear" <<'PY'
import json, sys
agent, iid, status, notify, clear = sys.argv[1:6]
ev = {"agent": agent, "instance_id": iid}
if status:  ev["status"] = status
if notify:  ev["notify"] = notify
if clear:   ev["clear"] = True
print(json.dumps(ev))
PY
)"

    "$AGENTS_STATUS_DIR/send" "$payload"
}

ensure_server() {
    "$AGENTS_STATUS_DIR/ensure-running"
}
