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

## TODO

### Wave 2 — Environment & PATH

Create `pwsh-conf/env.ps1` and `my-pwsh-conf/env.ps1` to port the environment setup from `zsh-conf/env.zsh` and `my-zsh-conf/env.zsh`.

Shared env (`env.ps1`):
- [ ] `$env:FZF_DEFAULT_OPTS = ""`
- [ ] PATH: `~/.local/bin`
- [ ] PATH: `~/.npm-packages/bin`

Personal env (`my-pwsh-conf/env.ps1`):
- [ ] `$env:GOPATH = "$HOME\go"` and `$GOPATH\bin` on PATH
- [ ] `$env:CARGO_NET_GIT_FETCH_WITH_CLI = "true"` and `.cargo\bin` on PATH
- [ ] `$env:RIPGREP_CONFIG_PATH = "$HOME\.ripgreprc"`
- [ ] `$env:EDITOR = "kv"` (with nvim check)
- [ ] `$env:MANPAGER = "kv +Man!"` and `$env:MANWIDTH = "999"`
- [ ] PATH: `~/.local/share/nvim/mason/bin` (Mason LSPs)
- [ ] PATH: `~/dotfiles_scripts/notify`, `misc`, `inner`, `git`, `cursor`
- [ ] PATH: `~/agents-status/simple-wrappers`
- [ ] `$env:NEOGIT = "true"` and `$env:KOALA_CODE_DIFF = "true"`
- [ ] `$env:AWS_PROFILE = "dev"`
- [ ] Source `$HOME\secrets.ps1` if it exists
- [ ] Skip tmux-specific PATH entries (`tmux_layouts`, `tmux`, `settings`)
- [ ] Skip Linux-only entries (pnpm Linux path, Wayland, LD_LIBRARY_PATH, spicetify)

### Wave 3 — Shell behavior & settings

PSReadLine settings to match OMZ defaults:
- [ ] History: `MaximumHistoryCount` (50000), `HistoryNoDuplicates`, `HistorySaveStyle IncrementalAndFlush`
- [ ] Auto-cd: directory name alone changes directory — needs `Set-PSReadLineOption` or custom `CommandNotFoundHandler`

### Wave 4 — Missing aliases & functions

Personal aliases present in zsh but not yet ported:
- [ ] `del` / `new` — `ez session delete` / `ez session new`
- [ ] `ez` shell init — `ez init-shell powershell` (if supported, else manual cd wrapper)
- [ ] `ezp` / `ezw` — ez with workspace flag
- [ ] `venv` — Python virtualenv activation (`. .\Scripts\Activate.ps1` on Windows)
- [ ] `cdw` — cd to worktree (needs Windows adaptation, no tmux session)
- [ ] `pg` — cd to playgrounds and open neovim
- [ ] `notes` — currently hardcodes "general", should use workspace/project name
- [ ] `ssh` wrapper — TERM=xterm-256color
- [ ] `cls` — `Clear-Host` (simpler on Windows without tmux)
- [ ] `gfork` — fork workflow (rename origin, fork, set push defaults, switch accounts)
- [ ] `gh_select_account` — fzf-based GitHub account switcher
- [ ] `mdp` — `gh markdown-preview --full`
- [ ] `up` function — cd ../../.. by count
- [ ] `cdl` — cd to last argument

cd-to-git plugin replacement:
- [ ] Port `cg` function (fzf over git repos in a directory)
- [ ] `cgp`, `cgw`, `cgnp`, `cgk`, `cgg` aliases

### Wave 5 — Hooks & post-init

- [ ] Starship auto-regen: check source toml mtimes on profile load, call `_gen_starship` if stale
- [ ] `notes` function: derive session/project name (from ez, komorebi workspace, or pwd)
- [ ] Source `$HOME\.extra_utils` if it exists (post-init equivalent)

### Not porting (by design)

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
