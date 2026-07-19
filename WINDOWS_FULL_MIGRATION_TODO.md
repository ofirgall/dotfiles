# Windows Full Migration TODO

Outstanding items from porting macOS-support features to win-support.
These need manual decisions or upstream changes before they can be completed.

## agents-status YASB Integration

The `[statusbar]` section was added to `agents-status-config-windows.toml`
with `workspaces_provider = "komorebi"` and `bar = "yasb"`, but this depends
on agents-status upstream supporting YASB as a bar backend.

- [ ] Verify agents-status supports `bar = "yasb"` (or if it needs to be implemented)
- [ ] If not supported, implement YASB widget/plugin in agents-status for Windows
- [ ] Wire up the post-event command to refresh YASB (equivalent to `run.py` refreshing sketchybar on macOS)

## tmux tnotify YASB Refresh

The tnotify_on_finish.sh and tnotify_on_start.sh scripts currently no-op
on MSYS2. On macOS they call `agents-status/statusbar/run.py` to refresh
the sketchybar. The Windows equivalent should refresh YASB status.

- [ ] Once agents-status YASB support lands, replace the MSYS2 no-op in tnotify scripts with YASB refresh call
- [ ] Same for hooks.tmux client-attached/detached hooks

## tmux hooks.tmux YASB Refresh

Same as above — hooks.tmux client-attached/detached currently no-op on
MSYS2. Should call YASB refresh once available.

- [ ] Replace `elif [ -n "$MSYSTEM" ]; then :;` with YASB statusbar refresh

## cursor-cli-wrapper on Windows

`install_scripts/windows/install_wrappers.sh` skips cursor-cli-wrapper
because it uses Unix PTY APIs not available on MSYS2.

- [ ] Check upstream cursor-cli-wrapper for Windows support
- [ ] If supported, enable the cargo install in install_wrappers.sh
- [ ] If not, consider a Windows-native alternative or contribute Windows PTY support upstream

## Windows Notification Sound

`windows_notify.ps1` supports BurntToast for rich toast notifications
with sound, falling back to balloon tips. The BurntToast module may not
be installed by default.

- [ ] Consider adding `Install-Module BurntToast -Scope CurrentUser` to `setup_once.sh` or a dedicated install step
- [ ] Test that balloon tip fallback works correctly without BurntToast

## Ghostty vs WinGhostty

Windows currently has two ghostty configs:
1. `config.windows` — platform override loaded by the shared ghostty config via `config.platform` symlink
2. `config-winghostty` — standalone full config for winghostty (AppData symlink)

These may diverge over time.

- [ ] Determine if winghostty can use the shared config + platform override mechanism instead of a standalone config
- [ ] If so, consolidate to eliminate `config-winghostty` duplication

## install_dap.sh for Windows

The shared `install_scripts/install_dap.sh` installs codelldb (C/C++/Rust
debugger) for Linux. No Windows version exists.

- [ ] Create `install_scripts/windows/install_dap.sh` that downloads `codelldb-win32-x64.vsix`
- [ ] Add to windows.conf.yaml install pipeline

## uv Package Manager

macOS installs `uv` via brew for agents-status package management.
Windows agents-status install uses `uv` if available but doesn't install it.

- [ ] Add `uv` installation to Windows — either via `cargo install uv` or `winget install astral-sh.uv`
- [ ] Add to install_msys2_packages.sh or install_basic.sh
