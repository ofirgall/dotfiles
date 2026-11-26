# aerospace-scripts

Compiled Rust replacement for AeroSpace shell scripts. Talks directly to the AeroSpace Unix socket instead of spawning `aerospace` CLI processes, so keybindings feel instant.

## Architecture

- `src/ipc.rs` — AeroSpace socket IPC. Connects once, reuses the connection for all commands in a single invocation.
- `src/main.rs` — CLI entry point and all subcommands. Each subcommand is a function taking `&mut Connection`.

## AeroSpace IPC protocol

Socket: `/tmp/bobko.aerospace-$USER.sock`

1. Handshake: both sides send a 4-byte LE u32 (`SOCKET_PROTOCOL_VERSION = 1`)
2. Messages: 4-byte LE u32 length prefix + UTF-8 JSON payload
3. Request: `{"args": ["cmd", "arg1"], "stdin": "", "windowId": null, "workspace": null}`
4. Response: `{"exitCode": 0, "stdout": "...", "stderr": "...", "serverVersionAndHash": "..."}`
5. Multiple request/response pairs can be sent on the same connection

Full protocol docs: https://nikitabobko.github.io/AeroSpace/guide.html#socket-protocol

## Adding a new command

1. Add a function in `main.rs`: `fn my_cmd(conn: &mut Connection) { ... }`
2. Add a match arm in `main()`
3. Use `conn.run()` (fire-and-forget), `conn.query()` (read stdout), or `conn.send()` (full response)
4. Update `aerospace.toml` binding to point at `aerospace-scripts my-cmd`

## Conventions

- No external CLI framework — just `std::env::args()`.
- Keep dependencies minimal (only serde/serde_json).
- Errors in keybinding scripts should fail silently (return `None`, don't panic).
- `make build` compiles, `make install` copies to `~/.local/bin/`. The toml config references `~/.local/bin/aerospace-scripts`.

## Useful AeroSpace format fields

Used via `list-windows --focused --format`:
- `%{window-id}`, `%{workspace}`, `%{monitor-id}`
- `%{window-layout}` — parent container layout: `h_tiles`, `v_tiles`, `h_accordion`, `v_accordion`, `floating`
- `%{app-name}`, `%{app-bundle-id}`, `%{window-title}`
