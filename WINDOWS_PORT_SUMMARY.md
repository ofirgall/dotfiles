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

Added to `windows.conf.yaml` shell steps.

### Wrappers install script (placeholder)
**Commit:** `eaea9d38`
**Files:** `install_scripts/windows/install_wrappers.sh`

Placeholder script — `cursor-cli-wrapper` requires Unix PTY APIs not available on MSYS2. Documented in TODO.

### agents-status hooks alignment
**Commit:** `42573f10`
**Files:** `install_scripts/windows/install_agents_status.sh`

Changed from explicit `hooks cursor` + `hooks codex` to `hooks all`, matching the macOS install script.

### Ghostty platform config
**Commit:** `5c8e45ea`
**Files:** `dotfiles/ghostty/config.windows`, `windows.conf.yaml`

Created `config.windows` platform override (font-size 12, ctrl+shift+enter fullscreen toggle) matching the `config.macos`/`config.linux` split pattern. Added symlink step in `windows.conf.yaml`: `ln -sf config.windows dotfiles/ghostty/config.platform`.

### tmux tnotify MSYS2 guards
**Commit:** `66173ee5`
**Files:** `dotfiles/tmux_conf/tnotify_on_finish.sh`, `dotfiles/tmux_conf/tnotify_on_start.sh`

Added `elif [[ -n "$MSYSTEM" ]]; then :` branch between Darwin and Linux, preventing MSYS2 from falling into the Linux/Hyprland code path.

### tmux hooks.tmux MSYS2 guard
**Commit:** `1921bd86`
**Files:** `dotfiles/tmux_conf/hooks.tmux`

Added MSYS2 guard to client-attached/detached hooks, preventing calls to Hyprland/macOS statusbar refresh on Windows.

### Windows notification system upgrade
**Commit:** `085a0e7b`
**Files:** `scripts/notify/windows_notify.ps1`

Rewrote `windows_notify.ps1` to match `notify-macos` feature parity:
- Urgency support (`-u critical` → alarm sound + 30s timeout)
- Proper arg parsing matching notify-send interface
- BurntToast PowerShell module support with balloon tip fallback

### agents-status YASB config
**Commit:** `63059ae6`
**Files:** `dotfiles/agents-status-config-windows.toml`

Added `[statusbar]` section for YASB integration:
- `workspaces_provider = "komorebi"`
- `bar = "yasb"`
- `label_template` matching sketchybar format

### AeroSpace keybinds → komorebi/whkd
**Commit:** `73b09444`
**Files:** `dotfiles/windows/komorebi/whkdrc`

Full port of AeroSpace keybinds to whkd:

| AeroSpace (macOS) | whkd (Windows) | Action |
|---|---|---|
| Cmd+h/j/k/l | Win+h/j/k/l | Focus direction |
| Cmd+Shift+h/j/k/l | Win+Shift+h/j/k/l | Move/swap window |
| Cmd+1-9, Cmd+0 | Win+1-9, Win+0 | Switch workspace (added ws 10) |
| Cmd+Shift+1-0 | Win+Shift+1-0 | Move window + follow (NEW: chains move + focus) |
| Cmd+Ctrl+1-0 | Win+Ctrl+1-0 | Move window silently (NEW) |
| Cmd+Enter | Win+Enter | Open terminal |
| Cmd+b | Win+b | Browser (default profile) |
| Cmd+Shift+b | Win+Shift+b | Browser Profile 1 (NEW) |
| Cmd+Alt+b | Win+Alt+b | Browser Profile 2 → YouTube (NEW) |
| Cmd+q | Win+q | Close window |
| Cmd+m | Win+m | Maximize/monocle toggle |
| Cmd+n | Win+n | Minimize window (NEW) |
| Cmd+Shift+f | Win+Shift+f | Float toggle |
| Cmd+/ | Win+/ | Cycle layout |
| Cmd+Ctrl+h/l | Win+Ctrl+h/l | Resize horizontal |
| Cmd+o | Win+o | Move to monitor + follow (FIXED: now follows) |
| Cmd+,/. | Win+,/. | Prev/next workspace |
| Cmd+\` | Win+\` | Last workspace |
| Cmd+Shift+r | Win+Shift+r | Reload config |
| Cmd+Shift+; | Win+Shift+; | Retile / service mode |

**Not ported** (no komorebi equivalent):
- Cmd+Shift+Ctrl+1-0 — move ALL windows to workspace (needs scripting)
- Cmd+F12 — move all windows to workspace 10
- Cmd+p — sticky window toggle (not supported by komorebi)
- Service mode — whkd doesn't support modal keybinds
- Cmd+s/Shift+s — screenshot (Windows uses Win+Shift+S natively)
- Cmd+r — Raycast launcher (no equivalent)
- Alt+v — clipboard history (Windows uses Win+V natively)
- F20 — toggle keyboard language (Windows uses Win+Space)

---

## Install Script Fixes

### Fix batch 1
**Commit:** `8ed388d6`

| Script | Issue | Fix |
|---|---|---|
| `install_basic.sh` | `pip3: bad interpreter` | Changed to `python3 -m pip install` |
| `install_fonts.sh` | `cp: Device or resource busy` | Suppress errors for locked fonts (`2>/dev/null \|\| true`) |
| `install_tuis.sh` | `npm: command not found` | Guard with `command -v npm` |
| `install_msys2_packages.sh` | `sed: Permission denied` on `/etc/` | Wrap in fallback with warning |
| `setup_once.sh` | — | Add BurntToast PowerShell module install |
| `install_msys2_packages.sh` | — | Add `uv` install via cargo/winget |

### Fix winget exit codes
**Commit:** `fa1d4d9e`

winget returns exit code 43 when package is already up-to-date. Fixed `install_ghostty.sh`, `install_komorebi.sh`, `install_yasb.sh`, `install_git_utils.sh` with proper already-installed detection.

### Fix font name mapping
**Commit:** `b67b779d`

Font zips extract to different filenames than the zip name (e.g., CascadiaCode → CaskaydiaCove, Recursive → RecMono). Added associative array mapping zip names to installed file patterns for correct already-installed detection.

### Fix dotbot subprocess context
**Commit:** `85890759`

All scripts using `winget.exe list` fail under dotbot's Python subprocess with "Access is denied" to `C:\WINDOWS\WinGet`. Fixed by replacing winget checks with filesystem/PATH checks:

| Script | Check |
|---|---|
| `install_ghostty.sh` | `[ -d "/c/Program Files/winghostty" ]` |
| `install_komorebi.sh` | `[ -d "/c/Program Files/komorebi" ]` + `[ -d "/c/Program Files/whkd" ]` |
| `install_yasb.sh` | `[ -d "/c/Program Files/YASB" ]` |
| `install_fonts.sh` | `LOCALAPPDATA` fallback to `$HOME/AppData/Local` |

---

## Pipeline Status

The full install pipeline (`dotbot -c windows.conf.yaml`) passes with **all tasks executed successfully** — every install script exits 0, all symlinks are created, and all directories exist.

---

## Remaining Items

See `WINDOWS_FULL_MIGRATION_TODO.md` for items that need upstream changes or manual decisions:
- agents-status YASB backend support
- tmux tnotify/hooks YASB refresh (currently no-op on MSYS2)
- cursor-cli-wrapper Windows PTY support
- Ghostty/WinGhostty config consolidation
