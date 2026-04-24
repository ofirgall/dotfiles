#!/usr/bin/env python3
"""Agent status aggregation server.

Hook scripts (claude / cursor) send JSON events over a Unix datagram socket.
Events are debounced per-instance — the latest state wins after DEBOUNCE_MS
of quiet. The server owns all side-effects: tmux window-local options,
desktop notifications, and the hypr workspace rename.

Event shape:
    {
      "agent": "claude" | "cursor",
      "instance_id": "tmux:<session>:<window>" | "tty:<tty>",
      "status": "IDLE" | "INPROGRESS" | "WAITING",   # optional
      "notify": "Done" | "Requires Permission" | ...,  # optional
      "clear": true                                     # optional (session-end)
    }
"""

import json
import os
import socket
import subprocess
import sys
import threading

SOCKET_PATH = f"/tmp/agent-status-{os.getuid()}.sock"
DEBOUNCE_MS = 1500

_pending = {}
_timers = {}
_lock = threading.Lock()


def _run(cmd):
    try:
        subprocess.run(cmd, check=False, timeout=5,
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except Exception:
        pass


def apply_state(instance_id, state):
    agent = state.get("agent") or ""
    status = state.get("status")
    notify_msg = state.get("notify")
    clear = state.get("clear", False)

    if notify_msg:
        title = f"❇️ {agent.capitalize() or 'Agent'} {notify_msg} ❇️"
        lines = []
        tmux_sess = state.get("tmux_session")
        tmux_win = state.get("tmux_window")
        if tmux_sess and tmux_win:
            lines.append(f"TMUX: {tmux_sess}#{tmux_win}")
        elif tmux_sess:
            lines.append(f"TMUX: {tmux_sess}")
        repo = state.get("repo")
        if repo:
            lines.append(f"Repo: {repo}")
        branch = state.get("branch")
        if branch:
            lines.append(f"Branch: {branch}")
        if not lines:
            lines.append(f"INSTANCE: {instance_id}")
        _run(["notify-send", title, "\n".join(lines)])

    if instance_id.startswith("tmux:"):
        target = instance_id[len("tmux:"):]
        if clear:
            _run(["tmux", "set-option", "-wqu", "-t", target, "@ai-agent-status"])
            _run(["tmux", "set-option", "-wqu", "-t", target, "@ai-agent"])
        else:
            if agent:
                _run(["tmux", "set-option", "-wq", "-t", target, "@ai-agent", agent])
            if status:
                _run(["tmux", "set-option", "-wq", "-t", target, "@ai-agent-status", status])

    script = os.path.expanduser("~/.config/hypr/UserScripts/RenameWorkspaces.py")
    if os.access(script, os.X_OK):
        try:
            subprocess.Popen([script], stdout=subprocess.DEVNULL,
                             stderr=subprocess.DEVNULL, start_new_session=True)
        except Exception:
            pass


def flush(instance_id):
    with _lock:
        state = _pending.pop(instance_id, None)
        _timers.pop(instance_id, None)
    if state:
        apply_state(instance_id, state)


def handle_event(event):
    instance_id = event.get("instance_id") or "default"
    with _lock:
        prev = _pending.get(instance_id, {})
        merged = dict(prev)
        for k in ("agent", "status", "notify", "clear",
                  "tmux_session", "tmux_window", "repo", "branch"):
            if k in event:
                merged[k] = event[k]
        _pending[instance_id] = merged

        t = _timers.get(instance_id)
        if t is not None:
            t.cancel()
        nt = threading.Timer(DEBOUNCE_MS / 1000.0, flush, args=(instance_id,))
        nt.daemon = True
        _timers[instance_id] = nt
        nt.start()


def main():
    if os.path.exists(SOCKET_PATH):
        try:
            os.unlink(SOCKET_PATH)
        except OSError:
            pass
    s = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
    s.bind(SOCKET_PATH)
    os.chmod(SOCKET_PATH, 0o600)
    print(f"agents-status server listening on {SOCKET_PATH}", flush=True)
    while True:
        try:
            data, _ = s.recvfrom(8192)
            event = json.loads(data.decode("utf-8"))
            handle_event(event)
        except Exception as e:
            print(f"error: {e}", file=sys.stderr, flush=True)
            continue


if __name__ == "__main__":
    main()
