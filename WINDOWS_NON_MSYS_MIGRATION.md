# Windows Non-MSYS2 Migration

Migrating the Windows dotfiles setup from MSYS2/zsh/tmux to native Windows: PowerShell 7 + PSReadLine + Starship, with Git Bash as the runner for install scripts.

## Done

### Wave 1 — Core shell UX + Aliases & functions
- [x] PowerShell 7 profile (`pwsh-conf/` + `my-pwsh-conf/`) mirroring zsh-conf two-layer pattern
- [x] PSReadLine: vi mode, history predictions, bell off
- [x] Starship prompt with `_gen_starship` merge helper
- [x] PSFzf: Ctrl+R history, Ctrl+T file search, Tab fzf-tab completion
- [x] All shared git aliases (ga, gc, gcm, gco, gd, gf, gl, gp, gs, etc.)
- [x] Personal kv/neovim wrappers (nv, v, gd, ghs, ai, g, gt)
- [x] Clipboard helpers (pwdc, pwdcd, cbranch, ccmt, cticket)
- [x] Ticket/JIRA helpers
- [x] GitHub aliases (gpc, gpv, gpvc, gpar, ghd) and gh-notify/gh-notify-pr
- [x] eza/ls aliases
- [x] yazi `y` function with cwd tracking
- [x] cd shortcuts (cdd, cdn, cdz, cdZ, cdr, plans)
- [x] Completion caching framework (Register-CachedCompletion)
- [x] Keybindings: Ctrl+Space accept suggestion, Ctrl+X Ctrl+E edit in editor, Alt+; forward word
- [x] `install-windows.ps1` rewritten: uses system Python + Git Bash instead of MSYS2
- [x] `windows.conf.yaml`: all shell commands use Git Bash full path, zsh/tmux/MSYS2 refs removed
- [x] Install scripts added: install_pwsh.sh, install_vcbuildtools.sh
- [x] python3 shim in install_agents_status.sh for WindowsApps stub workaround
- [x] fzf and starship install via winget in install_basic.sh
- [x] Removed: install_msys2_packages.sh, install_tmux.sh, libtmux pip install

### Wave 2 — Environment & PATH
- [x] Shared `env.ps1`: `Add-ToPath`/`Append-ToPath` helpers, FZF_DEFAULT_OPTS, ~/.local/bin, ~/.npm-packages/bin
- [x] Personal `my-pwsh-conf/env.ps1`: GOPATH, CARGO_NET_GIT_FETCH_WITH_CLI, RIPGREP_CONFIG_PATH, EDITOR/MANPAGER/MANWIDTH, Mason bin, dotfiles_scripts PATH entries, agents-status wrappers, NEOGIT/KOALA_CODE_DIFF, AWS_PROFILE, secrets sourcing
- [x] Profile sources env.ps1 before settings.ps1

### Wave 3 — Shell behavior & settings
- [x] History: MaximumHistoryCount 50000, HistoryNoDuplicates, SaveIncrementally
- [x] Auto-cd via CommandNotFoundAction

### Wave 4 — Missing aliases & functions
- [x] `del` / `new` — ez session delete/new
- [x] `ez` shell init — manual cd wrapper (ez doesn't support powershell natively)
- [x] `ezp` / `ezw` — ez with workspace flag
- [x] `venv` — `. .\Scripts\Activate.ps1`
- [x] `pg` — cd to playgrounds and open neovim
- [x] `notes` — uses current directory name as session
- [x] `ssh` wrapper — TERM=xterm-256color
- [x] `cls` — Clear-Host
- [x] `gfork` — fork workflow
- [x] `gh_select_account` — fzf-based GitHub account switcher
- [x] `mdp` — gh markdown-preview
- [x] `up` — cd ../../.. by count
- [x] `cdl` — cd to last argument
- [x] `cg` — fzf over git repos in a directory
- [x] `cgp`, `cgw`, `cgnp`, `cgk`, `cgg` aliases

### Wave 5 — Hooks & post-init
- [x] Starship auto-regen: checks source toml mtimes on profile load, calls `_gen_starship` if stale
- [x] Fixed Out-File to use utf8NoBOM encoding for starship config
- [x] Source `$HOME\.extra_utils.ps1` if it exists (post-init equivalent)

## Not porting (by design)

Dropped because we removed tmux or they're Linux-specific:
- tmux plugin, aliases (`tkill`, `trename`, `t`, `cls` tmux variant), tmux hooks, auto-tmux session launch, tmux window rename, tmux-notify, `ZSH_TMUX_*` vars
- `chpwd` hook for asdf `.tool-versions` (asdf is not used on Windows)
- `zsh-histdb` (SQLite history) — PSReadLine history is sufficient
- `zsh-autopair` — no PSReadLine equivalent
- `fast-syntax-highlighting` — PSReadLine provides syntax highlighting natively
- `sudo` ESC-ESC — not applicable on Windows
- OMZ libraries: `correction.zsh`, `grep.zsh`, `misc.zsh` — minor ergonomics, not needed
- `binaries.zsh` (zinit binary management) — handled by install scripts via winget/cargo
- Linux system aliases: `wifi`, `audio`, `lock`, `unlock`, `demo`, `drop_cache`, `notify` (notify-send)
- Wayland display fix, fusuma daemon, LD_LIBRARY_PATH
- Volumez work aliases (`capi`, `csio`, `db`, `lsj`, `ectl`)
- `drift-mcp-auth` (Cursor MCP auth symlink — project-specific)
- `nv-10`, `lz`, `lzlog` (alternate neovim profiles)
- `open-codex-plan` (codex-specific, uses mdp)
