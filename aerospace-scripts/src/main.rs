mod ipc;

use ipc::Connection;
use std::io::Write;
use std::process::ExitCode;

fn main() -> ExitCode {
    let args: Vec<String> = std::env::args().collect();
    let usage = || -> ExitCode {
        eprintln!("Usage: aerospace-scripts <command> [args...]");
        ExitCode::FAILURE
    };

    let Some(cmd) = args.get(1) else { return usage() };
    let dir = || -> &str {
        args.get(2).map(|s| s.as_str()).unwrap_or_else(|| std::process::exit(1))
    };

    let Some(mut conn) = Connection::connect() else {
        return ExitCode::FAILURE;
    };

    match cmd.as_str() {
        "focus" => focus(&mut conn, dir()),
        "swap" => swap(&mut conn, dir()),
        "cycle" => cycle(&mut conn),
        "minimize" => minimize(&mut conn),
        "unminimize" => unminimize(),
        "close" => close(&mut conn),
        "sticky-toggle" => sticky_toggle(&mut conn),
        "move-to-group" => move_to_group(&mut conn, dir(), args.get(3).map(|s| s.as_str())),
        "switch-group" => switch_group(&mut conn, dir()),
        "switch-group-relative" => switch_group_relative(&mut conn, dir()),
        "switch-group-back" => switch_group_back(&mut conn),
        "move-all-to-group" => move_all_to_group(&mut conn, dir()),
        "move-all-windows-to-group" => move_all_windows_to_group(&mut conn, args.get(2).map(|s| s.as_str())),
        _ => return usage(),
    }

    ExitCode::SUCCESS
}

/// Focus the next visible window, skipping hidden accordion siblings.
fn focus(conn: &mut Connection, dir: &str) {
    let layout = conn
        .query(&["list-windows", "--focused", "--format", "%{window-layout}"])
        .unwrap_or_default();

    let skip = matches!(
        (layout.as_str(), dir),
        ("h_accordion", "left" | "right") | ("v_accordion", "up" | "down")
    );

    if skip {
        conn.run(&["focus-monitor", "--wrap-around", dir]);
    } else {
        conn.run(&["focus", "--boundaries", "all-monitors-outer-frame", dir]);
    }

    if !conn.run(&["move-mouse", "window-lazy-center"]) {
        conn.run(&["move-mouse", "monitor-lazy-center"]);
    }
}

/// Swap focused window with neighbor; works across monitors.
fn swap(conn: &mut Connection, dir: &str) {
    let src = conn
        .query(&[
            "list-windows", "--focused", "--format", "%{window-id}\t%{workspace}",
        ])
        .unwrap_or_default();
    let Some((src_id, src_ws)) = src.split_once('\t') else { return };
    if src_id.is_empty() {
        return;
    }

    if conn.run(&["move", "--boundaries", "workspace", "--boundaries-action", "fail", dir]) {
        return;
    }

    if !conn.run(&["focus", "--boundaries", "all-monitors-outer-frame", dir]) {
        return;
    }

    let dst = conn
        .query(&[
            "list-windows", "--focused", "--format", "%{window-id}\t%{workspace}",
        ])
        .unwrap_or_default();
    let Some((dst_id, dst_ws)) = dst.split_once('\t') else { return };

    if src_id == dst_id {
        return;
    }

    conn.run(&["move-node-to-workspace", "--window-id", src_id, dst_ws]);
    conn.run(&["move-node-to-workspace", "--window-id", dst_id, src_ws]);
    conn.run(&["focus", "--window-id", src_id]);
}

/// Cycle to next window in workspace (DFS order, wrapping).
fn cycle(conn: &mut Connection) {
    conn.run(&["focus", "--wrap-around", "dfs-next"]);
}

const MINIMIZE_STACK: &str = "/tmp/aerospace-minimized-stack";
const STICKY_FILE: &str = "/tmp/aerospace-sticky-windows";
const CLOSE_REVERT: &str = "/tmp/aerospace-close-revert";
const SUFFIXES: [&str; 3] = ["", "b", "c"];

fn home() -> String {
    std::env::var("HOME").unwrap_or_default()
}

/// Minimize focused window, pushing its info onto a stack for later restore.
fn minimize(conn: &mut Connection) {
    let Some(info) = conn.query(&[
        "list-windows", "--focused", "--format", "%{window-id}|%{app-name}|%{window-title}",
    ]) else { return };
    if info.is_empty() { return; }

    if let Ok(mut f) = std::fs::OpenOptions::new().create(true).append(true).open(MINIMIZE_STACK) {
        let _ = writeln!(f, "{info}");
    }
    conn.run(&["macos-native-minimize"]);
}

/// Restore the most recently minimized window via AppleScript accessibility API.
fn unminimize() {
    use std::process::{Command, Stdio};

    let content = std::fs::read_to_string(MINIMIZE_STACK).unwrap_or_default();
    let mut lines: Vec<&str> = content.lines().collect();
    if lines.is_empty() { return; }

    let last = lines.pop().unwrap();
    let mut parts = last.splitn(3, '|');
    let _id = parts.next();
    let Some(app_name) = parts.next() else { return };
    let Some(window_title) = parts.next() else { return };

    let remaining = if lines.is_empty() { String::new() } else { lines.join("\n") + "\n" };
    let _ = std::fs::write(MINIMIZE_STACK, remaining);

    let script = r#"on run argv
    set appName to item 1 of argv
    set winTitle to item 2 of argv
    tell application "System Events"
        tell process appName
            set didRestore to false
            repeat with w in every window
                if value of attribute "AXMinimized" of w is true then
                    if value of attribute "AXTitle" of w is winTitle then
                        set value of attribute "AXMinimized" of w to false
                        set didRestore to true
                        exit repeat
                    end if
                end if
            end repeat
            if not didRestore then
                repeat with w in every window
                    if value of attribute "AXMinimized" of w is true then
                        set value of attribute "AXMinimized" of w to false
                        exit repeat
                    end if
                end repeat
            end if
        end tell
    end tell
    tell application appName to activate
end run"#;

    if let Ok(mut child) = Command::new("osascript")
        .arg("-").arg(app_name).arg(window_title)
        .stdin(Stdio::piped())
        .spawn()
    {
        if let Some(mut stdin) = child.stdin.take() {
            let _ = stdin.write_all(script.as_bytes());
        }
        let _ = child.wait();
    }
}

/// Close focused window, preventing macOS focus-stealing from switching workspace.
fn close(conn: &mut Connection) {
    use std::process::Command;

    let ws = conn.query(&["list-workspaces", "--focused"]).unwrap_or_default();
    let group = ws.trim_end_matches(['b', 'c']);
    let mon = conn.query(&["list-monitors", "--focused", "--format", "%{monitor-id}"]).unwrap_or_default();
    let app = conn.query(&["list-windows", "--focused", "--format", "%{app-bundle-id}"]).unwrap_or_default();

    let _ = std::fs::write(CLOSE_REVERT, format!("{group} {mon}"));

    match app.as_str() {
        "com.mitchellh.ghostty" | "com.lujjjh.LinearMouse" | "com.raycast.macos" => {
            let _ = Command::new("osascript")
                .arg("-e")
                .arg(r#"tell application "System Events" to keystroke "w" using command down"#)
                .status();
        }
        _ => {
            conn.run(&["close", "--quit-if-last-window"]);
        }
    }

    let h = home();
    let _ = Command::new("bash").arg("-c")
        .arg(format!(
            "sleep 1 && rm -f {CLOSE_REVERT} && {h}/dotfiles/dotfiles/mac/aerospace/on-window-detected.sh"
        ))
        .spawn();
}

/// Toggle sticky (follows across workspace groups) for the focused window.
fn sticky_toggle(conn: &mut Connection) {
    use std::process::Command;

    let Some(wid) = conn.query(&["list-windows", "--focused", "--format", "%{window-id}"]) else { return };
    if wid.is_empty() { return; }

    let content = std::fs::read_to_string(STICKY_FILE).unwrap_or_default();
    let is_sticky = content.lines().any(|l| l == wid);

    if is_sticky {
        let remaining: String = content.lines().filter(|&l| l != wid).map(|l| format!("{l}\n")).collect();
        let _ = std::fs::write(STICKY_FILE, remaining);
        let _ = Command::new("osascript").arg("-e")
            .arg(r#"display notification "Window unstickied" with title "Aerospace""#).spawn();
    } else {
        if let Ok(mut f) = std::fs::OpenOptions::new().create(true).append(true).open(STICKY_FILE) {
            let _ = writeln!(f, "{wid}");
        }
        let _ = Command::new("osascript").arg("-e")
            .arg(r#"display notification "Window stickied" with title "Aerospace""#).spawn();
    }
}

/// Move focused window to workspace group N on the same monitor.
fn move_to_group(conn: &mut Connection, group: &str, follow: Option<&str>) {
    use std::process::Command;

    let mon: usize = conn.query(&["list-monitors", "--focused", "--format", "%{monitor-id}"])
        .and_then(|s| s.parse().ok())
        .unwrap_or(1);
    let suffix = SUFFIXES.get(mon - 1).unwrap_or(&"");
    let target_ws = format!("{group}{suffix}");

    conn.run(&["move-node-to-workspace", &target_ws]);

    let h = home();

    if follow == Some("--follow") {
        let _ = Command::new("bash").arg("-c")
            .arg(format!("/opt/homebrew/bin/python3.14 {h}/agents-status/statusbar/run.py 2>/dev/null &"))
            .spawn();
        switch_group(conn, group);
        return;
    }

    let _ = Command::new(format!("{h}/agents-status/statusbar/sketchybar/update-ws-cache.sh")).status();
    let focused_group = std::fs::read_to_string("/tmp/aerospace-ws-cache")
        .unwrap_or_default().lines().next().unwrap_or("").to_string();

    let _ = Command::new("bash").arg("-c")
        .arg(format!("/opt/homebrew/bin/python3.14 {h}/agents-status/statusbar/run.py 2>/dev/null &"))
        .spawn();
    let _ = Command::new("/opt/homebrew/bin/sketchybar")
        .arg("--trigger").arg(format!("aerospace_workspace_change_{focused_group}"))
        .arg(format!("FOCUSED_WORKSPACE={focused_group}"))
        .arg("--trigger").arg(format!("aerospace_workspace_change_{group}"))
        .arg(format!("FOCUSED_WORKSPACE={focused_group}"))
        .spawn();
}

const WS_CACHE: &str = "/tmp/aerospace-ws-cache";
const SWITCH_LOCK: &str = "/tmp/aerospace-switch-group.lock";

/// Read current workspace group from cache, falling back to an aerospace query.
fn current_group(conn: &mut Connection) -> String {
    if let Ok(cache) = std::fs::read_to_string(WS_CACHE) {
        if let Some(first) = cache.lines().next() {
            if !first.is_empty() {
                return first.to_string();
            }
        }
    }
    conn.query(&["list-workspaces", "--focused"])
        .unwrap_or_default()
        .trim_end_matches(['b', 'c'])
        .to_string()
}

/// Switch all monitors to workspace group N atomically.
fn switch_group(conn: &mut Connection, group: &str) {
    use std::process::Command;

    // Serialize: only one switch-group at a time (mkdir is atomic)
    if std::fs::create_dir(SWITCH_LOCK).is_err() {
        return;
    }
    let _lock = LockGuard;

    let cur = current_group(conn);
    if cur == group {
        return;
    }

    let focused_mon: usize = conn
        .query(&["list-monitors", "--focused", "--format", "%{monitor-id}"])
        .and_then(|s| s.parse().ok())
        .unwrap_or(1);
    let num_monitors: usize = conn
        .query(&["list-monitors", "--format", "%{monitor-id}"])
        .map(|s| s.lines().count())
        .unwrap_or(1);

    // Save previous group for back-and-forth
    let _ = std::fs::write("/tmp/aerospace-prev-group", &cur);

    // Set flag so on-workspace-change hooks are no-ops during the batch
    let _ = std::fs::write("/tmp/aerospace-switching-group", "");

    // Update cache immediately (before workspace switches for responsiveness)
    let focused_ws = format!("{group}{}", SUFFIXES.get(focused_mon - 1).unwrap_or(&""));
    if let Ok(cache) = std::fs::read_to_string(WS_CACHE) {
        let mut lines: Vec<&str> = cache.lines().collect();
        if lines.is_empty() {
            lines.push(group);
        } else {
            lines[0] = group;
        }
        let _ = std::fs::write(WS_CACHE, lines.join("\n") + "\n");
    }

    // Trigger sketchybar in background (before switches for visual responsiveness)
    let _ = Command::new("/opt/homebrew/bin/sketchybar")
        .arg("--trigger").arg(format!("aerospace_workspace_change_{cur}"))
        .arg(format!("FOCUSED_WORKSPACE={focused_ws}"))
        .arg("--trigger").arg(format!("aerospace_workspace_change_{group}"))
        .arg(format!("FOCUSED_WORKSPACE={focused_ws}"))
        .spawn();

    // Pre-fetch sticky window locations if any exist
    let sticky_ids: Vec<String> = std::fs::read_to_string(STICKY_FILE)
        .unwrap_or_default()
        .lines()
        .filter(|l| !l.is_empty())
        .map(|l| l.to_string())
        .collect();

    let all_win_ws = if !sticky_ids.is_empty() {
        conn.query(&["list-windows", "--all", "--format", "%{window-id} %{workspace}"])
            .unwrap_or_default()
    } else {
        String::new()
    };

    // Build a single eval expression for all workspace switches + sticky moves
    let mut eval_cmd = String::new();

    for i in 0..num_monitors {
        let old_ws = format!("{cur}{}", SUFFIXES.get(i).unwrap_or(&""));
        let new_ws = format!("{group}{}", SUFFIXES.get(i).unwrap_or(&""));

        for wid in &sticky_ids {
            for line in all_win_ws.lines() {
                if let Some((id, ws)) = line.split_once(' ') {
                    if id == wid && ws == old_ws {
                        eval_cmd += &format!("move-node-to-workspace {new_ws} --window-id {wid}; ");
                    }
                }
            }
        }

        eval_cmd += &format!("workspace {new_ws}; ");
    }

    eval_cmd += &format!("focus-monitor {focused_mon}");

    // Single atomic IPC call
    conn.run(&["eval", &eval_cmd]);

    let _ = std::fs::remove_file("/tmp/aerospace-switching-group");
}

/// Switch to prev/next workspace group (wrapping 1-9).
fn switch_group_relative(conn: &mut Connection, direction: &str) {
    let cur: i32 = current_group(conn).parse().unwrap_or(1);

    let target = if direction == "prev" {
        if cur <= 1 { 9 } else { cur - 1 }
    } else {
        if cur >= 9 { 1 } else { cur + 1 }
    };

    switch_group(conn, &target.to_string());
}

/// Switch back to the previous workspace group (back-and-forth).
fn switch_group_back(conn: &mut Connection) {
    let prev = std::fs::read_to_string("/tmp/aerospace-prev-group").unwrap_or_default();
    let prev = prev.trim();
    if !prev.is_empty() {
        switch_group(conn, prev);
    }
}

/// Move all windows from the current group to target group N, then switch.
fn move_all_to_group(conn: &mut Connection, target: &str) {
    let cur = current_group(conn);
    if cur == target {
        return;
    }

    let num_monitors: usize = conn
        .query(&["list-monitors", "--format", "%{monitor-id}"])
        .map(|s| s.lines().count())
        .unwrap_or(1);

    let mut eval_cmd = String::new();
    for i in 0..num_monitors {
        let src_ws = format!("{cur}{}", SUFFIXES.get(i).unwrap_or(&""));
        let dst_ws = format!("{target}{}", SUFFIXES.get(i).unwrap_or(&""));

        if let Some(windows) = conn.query(&["list-windows", "--workspace", &src_ws, "--format", "%{window-id}"]) {
            for wid in windows.lines().filter(|l| !l.is_empty()) {
                eval_cmd += &format!("move-node-to-workspace {dst_ws} --window-id {wid}; ");
            }
        }
    }

    if !eval_cmd.is_empty() {
        conn.run(&["eval", &eval_cmd]);
    }

    switch_group(conn, target);
}

/// Move ALL windows from every workspace to target group, then switch.
fn move_all_windows_to_group(conn: &mut Connection, target: Option<&str>) {
    use std::process::Command;

    let target = target.unwrap_or("10");

    let focused_mon: usize = conn
        .query(&["list-monitors", "--focused", "--format", "%{monitor-id}"])
        .and_then(|s| s.parse().ok())
        .unwrap_or(1);
    let suffix = SUFFIXES.get(focused_mon - 1).unwrap_or(&"");
    let target_ws = format!("{target}{suffix}");

    let windows = conn
        .query(&["list-windows", "--all", "--format", "%{window-id}"])
        .unwrap_or_default();
    if windows.is_empty() {
        return;
    }

    let mut eval_cmd = String::new();
    for wid in windows.lines().filter(|l| !l.is_empty()) {
        eval_cmd += &format!("move-node-to-workspace {target_ws} --window-id {wid}; ");
    }

    if !eval_cmd.is_empty() {
        conn.run(&["eval", &eval_cmd]);
    }

    let _ = std::fs::remove_file(WS_CACHE);
    switch_group(conn, target);

    let h = home();
    let _ = Command::new(format!("{h}/dotfiles/dotfiles/mac/aerospace/on-window-detected.sh"))
        .spawn();
}

struct LockGuard;

impl Drop for LockGuard {
    fn drop(&mut self) {
        let _ = std::fs::remove_dir(SWITCH_LOCK);
    }
}
