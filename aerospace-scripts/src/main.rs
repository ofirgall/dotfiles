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
        let _ = Command::new(format!("{h}/dotfiles/dotfiles/mac/aerospace/switch-group.sh"))
            .arg(group).status();
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
