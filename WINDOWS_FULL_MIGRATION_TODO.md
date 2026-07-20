# Windows Full Migration TODO

Outstanding items from porting macOS-support features to win-support.

---

## cursor-cli-wrapper on Windows

`cursor-cli-wrapper` depends on the `pty-process` crate which uses Unix PTY APIs
(`std::os::unix`, `rustix::termios`, `rustix::pty`). These are fundamentally
unavailable on Windows — the crate would need a Windows ConPTY backend.

- [ ] Upstream: add `conpty` support to `pty-process` or fork `cursor-cli-wrapper` with a Windows ConPTY backend
- [ ] Once available, enable `cargo install` in `install_scripts/windows/install_wrappers.sh`

**Blocked:** requires upstream Rust crate changes.

## Ghostty vs WinGhostty Config Duplication

Windows has two ghostty configs:

1. `config.windows` (2 lines) — minimal platform override loaded by shared config via `config.platform` symlink
2. `config-winghostty` (95 lines) — full standalone config for winghostty (AppData symlink)

- [ ] Check if winghostty supports `config-file` directive to load the shared config chain
- [ ] If so, consolidate to eliminate `config-winghostty` duplication

---

## Completed

- [x] ~~agents-status YASB backend~~ — implemented `KomorebiWorkspacesProvider` + `YasbBar` in `~/agents-status/statusbar/komorebi/`
- [x] ~~tmux tnotify/hooks YASB refresh~~ — replaced MSYS2 no-ops with `python3 run.py` calls
- [x] ~~komorebi keybind gaps~~ — added scripts for move-all-to-workspace, move-all-windows-to-workspace, sticky-toggle with whkd binds
- [x] ~~AeroSpace keybinds port~~ — fully ported to whkdrc
- [x] ~~uv install~~ — in `install_msys2_packages.sh`
- [x] ~~BurntToast PowerShell module~~ — in `setup_once.sh`
- [x] ~~install_dap~~ — excluded per user request
