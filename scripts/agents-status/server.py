#!/usr/bin/env python3
"""Agent status aggregation server.

Hook scripts (claude / cursor) send JSON events over a Unix datagram socket.
State side-effects (tmux window-local options, hypr workspace rename) are
applied immediately. Notifications are debounced per-instance so a
short-lived "Done" superseded by a follow-up event within DEBOUNCE_MS does
not fire.

Event shape:
    {
      "agent": "claude" | "cursor",
      "instance_id": "tmux:<session>:<window>" | "tty:<tty>",
      "status": "IDLE" | "INPROGRESS" | "WAITING",   # optional
      "notify": "Done" | "Requires Permission" | ...,  # optional
      "clear": true,                                    # optional (session-end)
      "unset_status": true                              # optional (clear status only)
    }
"""

import json
import os
import socket
import subprocess
import sys
import threading
import time

DEBUG = os.environ.get("AGENTS_STATUS_DEBUG", "1") not in ("", "0", "false")


def _log(msg, *args):
    if not DEBUG:
        return
    ts = time.strftime("%H:%M:%S") + f".{int(time.time() * 1000) % 1000:03d}"
    if args:
        msg = msg % args
    print(f"[{ts}] {msg}", flush=True)

SOCKET_PATH = f"/tmp/agent-status-{os.getuid()}.sock"
DEBOUNCE_MS = 1500
# How long a `defer:true` event sits before being applied. A non-defer event
# for the same instance within this window drops the deferred event entirely
# (auto-run case). A subsequent defer event resets the timer (parallel
# permission requests — only the latest fires after the window settles).
DEFER_MS = 5000

_pending_notify = {}
_notify_timers = {}
_deferred_events = {}
_deferred_timers = {}
_lock = threading.Lock()


def _run(cmd):
    try:
        subprocess.run(cmd, check=False, timeout=5,
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except Exception:
        pass


def send_notification(instance_id, state):
    agent = state.get("agent") or ""
    notify_msg = state.get("notify")
    if not notify_msg:
        return
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


def apply_state(instance_id, state):
    agent = state.get("agent") or ""
    status = state.get("status")
    clear = state.get("clear", False)
    unset_status = state.get("unset_status", False)

    if instance_id.startswith("tmux:"):
        target = instance_id[len("tmux:"):]
        if clear:
            _run(["tmux", "set-option", "-wqu", "-t", target, "@ai-agent-status"])
            _run(["tmux", "set-option", "-wqu", "-t", target, "@ai-agent"])
            _run(["tmux", "setw", "-u", "-t", target, "@window_color"])
            _run(["tmux", "setw", "-u", "-t", target, "@window_color_dim"])
        else:
            if agent:
                _run(["tmux", "set-option", "-wq", "-t", target, "@ai-agent", agent])
            if unset_status:
                _run(["tmux", "set-option", "-wqu", "-t", target, "@ai-agent-status"])
                _run(["tmux", "setw", "-u", "-t", target, "@window_color"])
            if status:
                _run(["tmux", "set-option", "-wq", "-t", target, "@ai-agent-status", status])
                color = {
                    "WAITING": "#cf1313",
                    "INPROGRESS": "#fa7900",
                    "IDLE": "#15c70c",
                }.get(status)
                if color:
                    _run(["tmux", "setw", "-t", target, "@window_color", color])
                else:
                    _run(["tmux", "setw", "-u", "-t", target, "@window_color"])

    refresh = os.path.expanduser("~/.tmux_conf/refresh_dim_colors.sh")
    rename = os.path.expanduser("~/.config/hypr/UserScripts/RenameWorkspaces.py")

    def _spawn_followups():
        if os.access(refresh, os.X_OK):
            try:
                subprocess.run([refresh], timeout=5,
                               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            except Exception:
                pass
        if os.access(rename, os.X_OK):
            try:
                subprocess.Popen([rename], stdout=subprocess.DEVNULL,
                                 stderr=subprocess.DEVNULL, start_new_session=True)
            except Exception:
                pass

    # Small delay so the tmux option writes above are visible to scripts that
    # read tmux state (avoids races where they see stale state).
    t = threading.Timer(0.05, _spawn_followups)
    t.daemon = True
    t.start()


def flush_notify(instance_id):
    with _lock:
        state = _pending_notify.pop(instance_id, None)
        _notify_timers.pop(instance_id, None)
    if state:
        _log("notify fire %s: %s", instance_id, state.get("notify"))
        send_notification(instance_id, state)


def flush_deferred(instance_id):
    with _lock:
        event = _deferred_events.pop(instance_id, None)
        _deferred_timers.pop(instance_id, None)
    if not event:
        _log("defer flush %s: nothing pending", instance_id)
        return
    _log("defer flush %s: applying status=%s notify=%s",
         instance_id, event.get("status"), event.get("notify"))
    apply_state(instance_id, event)
    if event.get("notify"):
        send_notification(instance_id, event)


def _cancel_deferred(instance_id):
    dt = _deferred_timers.pop(instance_id, None)
    had = _deferred_events.pop(instance_id, None) is not None
    if dt is not None:
        dt.cancel()
    return had


def handle_event(event):
    instance_id = event.get("instance_id") or "default"
    _log("recv %s agent=%s status=%s notify=%s defer=%s clear=%s",
         instance_id, event.get("agent"), event.get("status"),
         event.get("notify"), event.get("defer"), event.get("clear"))

    # Any incoming event clears a pending deferred event. If the new event
    # is itself deferred, the timer just resets (parallel permission requests).
    # Otherwise the deferred event is dropped entirely (auto-run case).
    with _lock:
        had_pending = _cancel_deferred(instance_id)
    if had_pending and not event.get("defer"):
        _log("defer cancel %s (superseded by non-defer)", instance_id)

    if event.get("defer"):
        with _lock:
            _deferred_events[instance_id] = event
            dt = threading.Timer(DEFER_MS / 1000.0, flush_deferred,
                                 args=(instance_id,))
            dt.daemon = True
            _deferred_timers[instance_id] = dt
            dt.start()
        action = "reset" if had_pending else "schedule"
        _log("defer %s %s in %dms", action, instance_id, DEFER_MS)
        return

    apply_state(instance_id, event)

    with _lock:
        t = _notify_timers.pop(instance_id, None)
        if t is not None:
            t.cancel()
            _log("notify cancel %s (superseded)", instance_id)
        _pending_notify.pop(instance_id, None)

        if event.get("notify"):
            _pending_notify[instance_id] = event
            nt = threading.Timer(DEBOUNCE_MS / 1000.0, flush_notify,
                                 args=(instance_id,))
            nt.daemon = True
            _notify_timers[instance_id] = nt
            nt.start()
            _log("notify schedule %s in %dms (%s)",
                 instance_id, DEBOUNCE_MS, event.get("notify"))


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
