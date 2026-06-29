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
      "status": "IDLE" | "INPROGRESS" | "WAITING" | "DONE",  # optional
      "notify": "Done" | "Requires Permission" | ...,  # optional
      "clear": true,                                    # optional (session-end)
      "unset_status": true,                             # optional (clear status only)
      "subagent_delta": +1 | -1                         # optional (track active subagents)
    }

Subagent tracking: when subagent_delta is present the server adjusts a per-instance
counter. A DONE event arriving while the counter > 0 is held (not applied) until the
counter drops back to zero, preventing premature "Done" notifications while background
tasks are still running.
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
DEFER_MS = 30000

_pending_notify = {}
_notify_timers = {}
_deferred_events = {}
_deferred_timers = {}
_last_title = {}
_active_subagents = {}
_held_done = {}
_held_done_timers = {}
_lock = threading.Lock()

HELD_DONE_TIMEOUT_MS = 300000  # 5 minutes safety net


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
    cmd = ["notify-send"]
    urgency = state.get("urgency")
    if urgency:
        cmd += ["-u", urgency]
    can_focus = bool(tmux_sess and tmux_win)
    if can_focus:
        cmd += ["-A", "default=Focus"]
    cmd += [title, "\n".join(lines)]

    if not can_focus:
        _run(cmd)
        return

    def _run_with_action():
        try:
            r = subprocess.run(cmd, capture_output=True, timeout=3600, text=True)
        except Exception:
            return
        if r.stdout.strip() != "default":
            return
        focus = os.path.join(os.path.dirname(os.path.abspath(__file__)), "focus")
        if not os.access(focus, os.X_OK):
            return
        try:
            subprocess.Popen([focus, str(tmux_sess), str(tmux_win)],
                             stdout=subprocess.DEVNULL,
                             stderr=subprocess.DEVNULL,
                             start_new_session=True)
        except Exception:
            pass

    threading.Thread(target=_run_with_action, daemon=True).start()


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
            if _last_title.pop(instance_id, None) is not None:
                _run(["tmux", "rename-window", "-t", target, ""])
        else:
            title = state.get("tmux_title")
            if title and _last_title.get(instance_id) != title:
                _run(["tmux", "rename-window", "-t", target, title])
                _last_title[instance_id] = title
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
                    "DONE": "#1e88ff",
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
                subprocess.Popen(["hyprctl", "dispatch", "exec", rename],
                                 stdout=subprocess.DEVNULL,
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


def _flush_held_done(instance_id):
    """Fire a held DONE event after the safety timeout expires."""
    with _lock:
        event = _held_done.pop(instance_id, None)
        _held_done_timers.pop(instance_id, None)
        active = _active_subagents.get(instance_id, 0)
    if not event:
        return
    _log("done EXPIRED %s: held DONE timed out after %dms, active_subagents=%d (forcing fire)",
         instance_id, HELD_DONE_TIMEOUT_MS, active)
    apply_state(instance_id, event)
    if event.get("notify"):
        expired_event = dict(event, notify=f"{event['notify']} (timeout, {active} subagents unresolved)")
        send_notification(instance_id, expired_event)


def _cancel_held_done(instance_id):
    """Cancel a held DONE timer and discard the event. Returns whether one existed."""
    ht = _held_done_timers.pop(instance_id, None)
    had = _held_done.pop(instance_id, None) is not None
    if ht is not None:
        ht.cancel()
    return had


def handle_event(event):
    instance_id = event.get("instance_id") or "default"
    _log("recv %s agent=%s status=%s notify=%s defer=%s clear=%s subagent_delta=%s",
         instance_id, event.get("agent"), event.get("status"),
         event.get("notify"), event.get("defer"), event.get("clear"),
         event.get("subagent_delta"))

    # --- Subagent tracking ---
    delta = event.get("subagent_delta")
    if delta is not None:
        with _lock:
            prev = _active_subagents.get(instance_id, 0)
            new_count = max(0, prev + delta)
            _active_subagents[instance_id] = new_count
            _log("subagent delta %s: %+d -> active=%d", instance_id, delta, new_count)

            if new_count == 0 and instance_id in _held_done:
                held_event = _held_done.pop(instance_id)
                ht = _held_done_timers.pop(instance_id, None)
                if ht is not None:
                    ht.cancel()
                _log("done RELEASED %s: all subagents finished, firing held DONE",
                     instance_id)

                def _fire_held(iid=instance_id, ev=held_event):
                    apply_state(iid, ev)
                    if ev.get("notify"):
                        send_notification(iid, ev)

                threading.Thread(target=_fire_held, daemon=True).start()
        return

    # --- Session clear: drop held state ---
    if event.get("clear"):
        with _lock:
            had_held = _cancel_held_done(instance_id)
            _active_subagents.pop(instance_id, None)
        if had_held:
            _log("done DROPPED %s: session cleared while DONE was held", instance_id)

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

    # --- Hold DONE if subagents are still active ---
    if event.get("status") == "DONE":
        with _lock:
            active = _active_subagents.get(instance_id, 0)
        if active > 0:
            with _lock:
                _cancel_held_done(instance_id)
                _held_done[instance_id] = event
                ht = threading.Timer(HELD_DONE_TIMEOUT_MS / 1000.0,
                                     _flush_held_done, args=(instance_id,))
                ht.daemon = True
                _held_done_timers[instance_id] = ht
                ht.start()
            _log("done HELD %s: active_subagents=%d, waiting for subagents to finish",
                 instance_id, active)
            return
        else:
            _log("done IMMEDIATE %s: no active subagents, processing normally",
                 instance_id)

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
