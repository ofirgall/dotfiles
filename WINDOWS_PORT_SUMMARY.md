# Windows Port Summary

All features, tools, configs, and install scripts introduced on the `macos-support` branch (and merged to `master`) have been ported to the `win-support` branch for Windows/MSYS2 parity.

---

## Ported Features

### ez-workspaces config
**Commit:** `45ea3c2e`
**Files:** `dotfiles/ez-workspaces-windows/config.toml`

Ported all new features from macOS ez-workspaces config:
- `name_builder_modes` (full_name, build_from_parts, git_hub_pr, jira_url)
- `default_sort = "lru"`
- `copy_cursor_conversations = true`
- New keybinds: `cd_session`, `new_bare_session`, `sort_toggle`, `session_from_dirty`
- Cursor plugins: `cursor-mcp-auth`, `cursor-mcp-approvals`, `cursor-trusted-workspace`
- Changed hardcoded `C:/Users/Ofir/workspace/` to `~/workspace/`

### tmux bind W fix
**Commit:** `c66bcb1a`
**Files:** `dotfiles/tmux_conf/binds.tmux`

Ported the `bind W` refactor from macOS — replaced broken single-line `%%` syntax with multi-line `{ }` block using `%1`.

### bottom and hop config symlinks
**Commit:** `b814d443`
**Files:** `windows.conf.yaml`

Added missing symlinks from macOS config:
- `~/.config/bottom/bottom.toml`
- `~/.config/hop/config.toml`

### TUI tools install script
**Commit:** `8f28afb9`
**Files:** `install_scripts/windows/install_tuis.sh`

Created Windows equivalent of `install_scripts/install_tuis.sh`:
- `hunkdiff` via npm (guarded for npm availability)
- `lumen` and `ftdv` via cargo
- Skips `wiremix` (Linux-only, requires pipewire)

### Wrappers install script (placeholder)
**Commit:** `eaea9d38`
**Files:** `install_scripts/windows/install_wrappers.sh`

Placeholder — `cursor-cli-wrapper` depends on `pty-process` crate which uses Unix PTY APIs (`std::os::unix`, `rustix::termios`). Requires upstream ConPTY support.

### agents-status hooks alignment
**Commit:** `42573f10`
**Files:** `install_scripts/windows/install_agents_status.sh`

Changed from explicit `hooks cursor` + `hooks codex` to `hooks all`, matching the macOS install script.

### Ghostty platform config
**Commit:** `5c8e45ea`
**Files:** `dotfiles/ghostty/config.windows`, `windows.conf.yaml`

Created `config.windows` platform override (font-size 12, ctrl+shift+enter fullscreen toggle) matching the `config.macos`/`config.linux` split pattern. Added symlink step in `windows.conf.yaml`.

### tmux tnotify MSYS2 guards → YASB refresh
**Commits:** `66173ee5`, `6ccf9f05`
**Files:** `dotfiles/tmux_conf/tnotify_on_finish.sh`, `dotfiles/tmux_conf/tnotify_on_start.sh`

Initially added MSYS2 no-op guards, then wired to call `python3 ~/agents-status/statusbar/run.py` to refresh YASB workspace labels on agent status changes.

### tmux hooks.tmux → YASB refresh
**Commits:** `1921bd86`, `6ccf9f05`
**Files:** `dotfiles/tmux_conf/hooks.tmux`

client-attached/detached hooks now call `python3 run.py` on MSYS2 to refresh YASB statusbar (previously no-op).

### Windows notification system upgrade
**Commit:** `085a0e7b`
**Files:** `scripts/notify/windows_notify.ps1`

Rewrote `windows_notify.ps1` to match `notify-macos` feature parity:
- Urgency support (`-u critical` → alarm sound + 30s timeout)
- Proper arg parsing matching notify-send interface
- BurntToast PowerShell module support with balloon tip fallback

### agents-status komorebi + YASB backend
**Commits:** `63059ae6`, `4bf547c2` (dotfiles), `b09c807` (agents-status)
**Files:** `dotfiles/agents-status-config-windows.toml`, `dotfiles/windows/yasb/config.yaml`, `~/agents-status/statusbar/komorebi/`

Full agents-status integration for Windows:
- **KomorebiWorkspacesProvider** — queries `komorebic state` JSON, collects windows from containers, floating, and monocle layers
- **YasbBar** — sets workspace names via `komorebic workspace-name` so YASB displays agent status icons/tmux sessions, writes sentinel file for external scripts
- **Auto-detection** — `komorebic`/`komorebic.exe` on PATH triggers komorebi+yasb
- **YASB config** — changed workspace label from `{index}` to `{name}` to display enriched names
- **Post-event** — `run.py` added to `[post-event]` commands in agents-status config

### AeroSpace keybinds → komorebi/whkd
**Commits:** `73b09444`, `15f200d3`
**Files:** `dotfiles/windows/komorebi/whkdrc`, `scripts/komorebi/`

Full port of AeroSpace keybinds to whkd:

| AeroSpace (macOS) | whkd (Windows) | Action |
|---|---|---|
| Cmd+h/j/k/l | Win+h/j/k/l | Focus direction |
| Cmd+Shift+h/j/k/l | Win+Shift+h/j/k/l | Move/swap window |
| Cmd+1-9, Cmd+0 | Win+1-9, Win+0 | Switch workspace |
| Cmd+Shift+1-0 | Win+Shift+1-0 | Move window + follow |
| Cmd+Ctrl+1-0 | Win+Ctrl+1-0 | Move window silently |
| Cmd+Shift+Ctrl+1-0 | Win+Shift+Ctrl+1-0 | Move ALL windows from workspace |
| Cmd+F12 | Win+F12 | Move ALL windows (all ws) to ws 10 |
| Cmd+Enter | Win+Enter | Open terminal |
| Cmd+b | Win+b | Browser (default profile) |
| Cmd+Shift+b | Win+Shift+b | Browser Profile 1 |
| Cmd+Alt+b | Win+Alt+b | Browser Profile 2 → YouTube |
| Cmd+q | Win+q | Close window |
| Cmd+m | Win+m | Maximize/monocle toggle |
| Cmd+n | Win+n | Minimize window |
| Cmd+p | Win+p | Sticky window toggle |
| Cmd+Shift+f | Win+Shift+f | Float toggle |
| Cmd+/ | Win+/ | Cycle layout |
| Cmd+Ctrl+h/l | Win+Ctrl+h/l | Resize horizontal |
| Cmd+o | Win+o | Move to monitor + follow |
| Cmd+,/. | Win+,/. | Prev/next workspace |
| Cmd+\` | Win+\` | Last workspace |
| Cmd+Shift+r | Win+Shift+r | Reload config |
| Cmd+Shift+; | Win+Shift+; | Retile |

Komorebi helper scripts (`scripts/komorebi/`):
- `move-all-to-workspace.sh` — moves all windows from focused workspace via komorebic state iteration
- `move-all-windows-to-workspace.sh` — moves all windows from ALL workspaces
- `sticky-toggle.sh` — file-based sticky window registry at `$LOCALAPPDATA/komorebi-sticky/`

**Not ported** (native Windows alternatives):
- Cmd+s/Shift+s — screenshot (Windows uses Win+Shift+S)
- Cmd+r — launcher (Windows Start/PowerToys Run)
- Alt+v — clipboard history (Windows Win+V)
- F20 — toggle keyboard language (Windows Win+Space)
- Service mode — whkd doesn't support modal keybinds

---

## Install Script Fixes

### Fix batch 1
**Commit:** `8ed388d6`

| Script | Issue | Fix |
|---|---|---|
| `install_basic.sh` | `pip3: bad interpreter` | Changed to `python3 -m pip install` |
| `install_fonts.sh` | `cp: Device or resource busy` | Suppress errors for locked fonts |
| `install_tuis.sh` | `npm: command not found` | Guard with `command -v npm` |
| `install_msys2_packages.sh` | `sed: Permission denied` | Wrap in fallback with warning |
| `setup_once.sh` | — | Add BurntToast PowerShell module install |
| `install_msys2_packages.sh` | — | Add `uv` install via cargo/winget |

### Fix winget exit codes
**Commit:** `fa1d4d9e`

Replaced `winget list` checks with filesystem/PATH checks — winget fails with "Access is denied" under dotbot's Python subprocess context.

### Fix font name mapping
**Commit:** `b67b779d`

CascadiaCode→CaskaydiaCove, Recursive→RecMono mapping for correct already-installed detection.

### Fix dotbot subprocess env
**Commits:** `85890759`, `e7c427ff`

- `LOCALAPPDATA` fallback for `install_fonts.sh`
- `TMPDIR`/`TMP`/`TEMP` export for `install_basic.sh` (mingw gcc can't write temp files to `C:\WINDOWS\`)

---

## Pipeline Status

The full install pipeline (`dotbot -c windows.conf.yaml`) passes with **all tasks executed successfully**.

---

## Remaining Items

See `WINDOWS_FULL_MIGRATION_TODO.md`:
- **cursor-cli-wrapper** — needs upstream `pty-process` crate ConPTY support (confirmed: compile fails on Windows)
- **Ghostty config consolidation** — determine if winghostty supports `config-file` directive
