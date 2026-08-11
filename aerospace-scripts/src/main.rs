mod ipc;

use ipc::Connection;
use std::process::ExitCode;

fn main() -> ExitCode {
    let args: Vec<String> = std::env::args().collect();
    let usage = || -> ExitCode {
        eprintln!("Usage: aerospace-scripts <focus|swap|cycle> [left|right|up|down]");
        ExitCode::FAILURE
    };

    let Some(cmd) = args.get(1) else { return usage() };
    let dir = args.get(2).map(|s| s.as_str());

    let Some(mut conn) = Connection::connect() else {
        return ExitCode::FAILURE;
    };

    match cmd.as_str() {
        "focus" => focus(&mut conn, dir.unwrap_or_else(|| std::process::exit(1))),
        "swap" => swap(&mut conn, dir.unwrap_or_else(|| std::process::exit(1))),
        "cycle" => cycle(&mut conn),
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
