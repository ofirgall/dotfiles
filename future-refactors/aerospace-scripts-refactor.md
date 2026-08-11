# aerospace-scripts refactor

Redesign `aerospace-scripts` from its current 1:1 shell migration into a properly architected Rust project.

## Motivation

The current code is a direct port of shell scripts — every function lives in `main.rs` (615 lines), state is scattered across `/tmp/` constants, sketchybar is invoked by spawning the CLI binary, and `update-ws-cache.sh` from `agents-status` is called on the blocking path even though the Rust binary already has a live aerospace socket.

## Boundary fix: agents-status coupling

`agents-status` is a separate cross-platform repo. It should NOT contain aerospace-specific logic.

**Currently wrong**: `agents-status/statusbar/sketchybar/update-ws-cache.sh` calls `aerospace list-workspaces` and `aerospace list-windows`. This is aerospace workspace caching that leaked into a generic tool.

**Fix**: Move workspace cache logic into `aerospace-scripts`. The only contract between the two repos is the sentinel file at `/tmp/agent-status-bg-$UID`. `aerospace-scripts` calls `run.py` fire-and-forget — that's the only legitimate dependency.

After the fix, `update-ws-cache.sh` should be deleted from `agents-status` and `on-window-detected.sh` (which calls it) should be folded into the Rust binary.

## Architecture

```
aerospace-scripts/
├── src/
│   ├── main.rs           # CLI dispatch only
│   ├── aerospace.rs      # AeroSpace Unix socket IPC
│   ├── sketchybar.rs     # SketchyBar Unix socket IPC (replaces CLI spawning)
│   ├── state.rs          # Cache, sticky windows, minimize stack, locks
│   ├── groups.rs         # Grouped workspace logic (N → N, Nb, Nc)
│   ├── commands/
│   │   ├── mod.rs
│   │   ├── focus.rs
│   │   ├── window.rs     # close, minimize, unminimize, swap, cycle
│   │   ├── group.rs      # switch-group, relative, back, move-to, move-all
│   │   ├── sticky.rs     # toggle, move
│   │   └── hooks.rs      # on-workspace-change, on-window-detected, move-to-cursor-monitor
│   └── macos.rs          # osascript helpers (notify, keystroke, unminimize)
```

## Key changes

### 1. SketchyBar direct socket IPC

SketchyBar socket: `/tmp/sketchybar_$USER`

Instead of spawning `/opt/homebrew/bin/sketchybar --trigger ...` (fork+exec per trigger), send messages directly over the Unix socket. Same pattern as the AeroSpace IPC.

```rust
pub struct Sketchybar { stream: UnixStream }

impl Sketchybar {
    pub fn connect() -> Option<Self> { ... }
    pub fn trigger(&mut self, event: &str, vars: &[(&str, &str)]) { ... }
}
```

**Impact**: Eliminates process spawning from every workspace switch, move, and close.

### 2. Inline workspace cache (replace update-ws-cache.sh)

The cache update does 2 aerospace queries: `list-workspaces --focused` + `list-windows --all`. Fold this into a `state::update_ws_cache(conn)` that queries the existing socket and writes the cache file directly.

Cache format (unchanged — sketchybar plugin reads this):
```
<focused_group>
1 <has_windows> <win_count>
2 <has_windows> <win_count>
...
10 <has_windows> <win_count>
```

### 3. Context struct

```rust
struct Ctx {
    aero: Connection,
    bar: Sketchybar,
    state: State,
    groups: GroupedWorkspaces,
    home: String,
}
```

Query `num_monitors` and `focused_monitor` once in `Ctx::new()`. Every command takes `&mut Ctx`.

### 4. GroupedWorkspaces abstraction

Centralizes the group ↔ sub-workspace mapping currently duplicated everywhere:

```rust
struct GroupedWorkspaces { num_monitors: usize }

impl GroupedWorkspaces {
    fn sub_workspace(&self, group: &str, monitor: usize) -> String { ... }
    fn group_from_workspace(ws: &str) -> &str { ... }  // trim trailing b/c
    fn all_sub_workspaces(&self, group: &str) -> Vec<String> { ... }
}
```

### 5. State types with methods

Replace scattered `/tmp/` file constants with types that own their file path and provide read/write methods:

```rust
struct State {
    cache: WsCache,         // /tmp/aerospace-ws-cache
    sticky: StickyWindows,  // /tmp/aerospace-sticky-windows
    minimize: MinStack,     // /tmp/aerospace-minimized-stack
    prev_group: PrevGroup,  // /tmp/aerospace-prev-group
}
```

### 6. macos.rs helpers

Deduplicate osascript boilerplate used in close, sticky-toggle, unminimize, tmux-viewer:

```rust
pub fn notify(title: &str, msg: &str) { ... }
pub fn keystroke(key: &str, modifiers: &str) { ... }
pub fn unminimize_window(app: &str, title: &str) { ... }
```

## Current process spawning audit

Places in `main.rs` that spawn external processes (would be eliminated or reduced):

| Call | From | Blocking? | After refactor |
|---|---|---|---|
| `/opt/homebrew/bin/sketchybar --trigger` | switch_group, move_to_group, on_workspace_change | spawn (async) | sketchybar socket IPC |
| `update-ws-cache.sh` | move_to_group, on_workspace_change | `.status()` (blocking!) | inline, same aero connection |
| `on-window-detected.sh` | close, move_all_windows_to_group, on_workspace_change | mixed | fold into Rust (it's just cache update + sketchybar triggers) |
| `run.py` | move_to_group | spawn (async) | stays as-is (fire-and-forget, separate concern) |
| `osascript` | close, sticky_toggle, unminimize, tmux_viewer | mixed | stays (no socket API for osascript) |
| `bash -c "sleep 1 && ..."` | close | spawn (async) | stays (timer cleanup) |

## SketchyBar socket protocol reference

Socket: `/tmp/sketchybar_$USER`

Messages are newline-terminated strings. Trigger format:
```
--trigger <event> <KEY>=<VALUE> ...
```

Docs: https://felixkratz.github.io/SketchyBar/config/events
