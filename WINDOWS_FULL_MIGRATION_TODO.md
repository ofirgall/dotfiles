# Windows Full Migration TODO

Outstanding items from porting macOS-support features to win-support.
These need upstream changes, scripting, or manual decisions before they can be completed.

---

## agents-status: komorebi + YASB Backend

The `[statusbar]` section was added to `agents-status-config-windows.toml`
with `workspaces_provider = "komorebi"` and `bar = "yasb"`, but agents-status
`statusbar/run.py` only supports two providers (`hyprland`, `aerospace`) and
two bars (`hyprland`, `sketchybar`). Neither `komorebi` nor `yasb` exist yet.

- [ ] Implement `KomorebiWorkspacesProvider` in agents-status (similar to `AerospaceWorkspacesProvider`)
- [ ] Implement `YasbBar` backend in agents-status (similar to `SketchyBar`)
- [ ] Add `komorebi` auto-detection in `statusbar/common/config.py` `_auto_detect()`
- [ ] Wire up the post-event command to refresh YASB (equivalent to `run.py` refreshing sketchybar on macOS)

**Blocked:** agents-status upstream needs new code.

## tmux tnotify / hooks YASB Refresh

`tnotify_on_finish.sh`, `tnotify_on_start.sh`, and `hooks.tmux`
client-attached/detached hooks currently no-op on MSYS2. On macOS they call
`agents-status/statusbar/run.py` to refresh sketchybar.

- [ ] Once agents-status YASB support lands, replace the MSYS2 no-op with YASB refresh call
- [ ] Files: `dotfiles/tmux_conf/tnotify_on_finish.sh`, `tnotify_on_start.sh`, `hooks.tmux`

**Blocked by:** agents-status komorebi+YASB backend above.

## cursor-cli-wrapper on Windows

`install_scripts/windows/install_wrappers.sh` skips cursor-cli-wrapper
because it uses Unix PTY APIs not available on MSYS2. Not currently installable
via cargo on Windows.

- [ ] Check upstream cursor-cli-wrapper for Windows/ConPTY support
- [ ] If supported, enable the cargo install in `install_wrappers.sh`
- [ ] If not, consider a Windows-native alternative or contribute Windows PTY support upstream

## Ghostty vs WinGhostty Config Duplication

Windows has two ghostty configs serving different purposes:

1. `config.windows` (2 lines) — minimal platform override loaded by shared config via `config.platform` symlink
2. `config-winghostty` (95 lines) — full standalone config for winghostty (AppData symlink), includes font, colors, keybinds, MSYS2 command

These will diverge. `config-winghostty` duplicates the shared config's font,
colors, keybinds, and padding settings rather than loading them.

- [ ] Determine if winghostty can use the shared config + `config.platform` override mechanism
- [ ] If so, consolidate to eliminate `config-winghostty` duplication
- [ ] If not (e.g. winghostty doesn't support `config-file` directive), keep both and document

## Komorebi Keybind Gaps

Some AeroSpace features have no komorebi equivalent:

- [ ] **Move ALL windows to workspace** (AeroSpace: Cmd+Shift+Ctrl+1-0, Cmd+F12) — needs a PowerShell/bash script to iterate `komorebic state` and move each window
- [ ] **Sticky window toggle** (AeroSpace: Cmd+p) — keep a window visible across all workspaces; not natively supported by komorebi
- [ ] **Service/modal keybinds** (AeroSpace: Cmd+Shift+;) — whkd doesn't support modes

---

## Completed

- [x] ~~uv install~~ — added to `install_msys2_packages.sh`
- [x] ~~BurntToast PowerShell module~~ — added to `setup_once.sh`
- [x] ~~AeroSpace keybinds port~~ — fully ported to whkdrc (see `WINDOWS_PORT_SUMMARY.md`)
- [x] ~~install_dap~~ — excluded per user request
