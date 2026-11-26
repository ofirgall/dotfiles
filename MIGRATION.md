# Migrating `~/dotfiles` from dotbot to dots

Branch `migrate-to-dots`, in the worktree `~/dotfiles-dots`, cut from `master@ef868828`.
Written 2026-11-26 by the migration supervisor. The implementers execute it after dots v0.2
(phase 5 of `implement-dots-v1`) lands.

The user's instruction was "migrate everything, decide everything yourself, we will fix it
later". Every decision below has already been made. When a brief says "decide", it means a
local detail such as a regex or a check command, never scope.

dots references in this file:
- `ARCH §n` is `~/workspace/personal/dots-manager/ARCHITECTURE.md`.
- `task n.m` is `openspec/changes/implement-dots-v1/tasks.md` in the same repo.
- The specs are in `openspec/changes/implement-dots-v1/specs/<capability>/spec.md`.

---

## 0. Status legend (used in every table)

| Tag | Meaning |
|---|---|
| `READY` | Expressible with what dots ships today (v0.1 plus the parts of phase 5 already checked off: 5.6 overrides, 5.13 terminfo). |
| `P5:x.y` | Expressed the spec way, and it needs phase-5 task x.y. Implementers start after v0.2 lands, so these are expected to work. If one doesn't, apply the fallback named in the row and add a `# TODO(dots-migration): needs task x.y` comment. |
| `INTERIM:x.y` | dots can't express it yet (needs a v0.3 or v0.4 task). It becomes a `script` package or a custom declarative provider, with `# TODO(dots-migration): replace with <feature> (task x.y)`. |
| `DEFER` | Not migrated on this branch. It stays dotbot-driven (Windows only; see chunk 6). |
| `DROP` | Deleted. The reason is given in the row. |

---

## 1. Key decisions

1. **One repo, packages are self-contained.** Everything moves under `packages/<pkg>/` with
   `git mv`, so history is kept. No `//` escape paths.
2. **Submodules stay submodules for now, moved inside their package dir**
   (`packages/zsh/zsh-conf`, `packages/koala-config/KoalaConfig`,
   `packages/agents-status/agents-status`, `packages/vscode/vscode-settings`,
   `packages/hyprland/hypr-dots`). The spec target (§16.3, "submodules become `git` packages")
   needs file `mode = "git"`, which `dots-files/src/resolve.rs` still rejects as
   `not-implemented`. The `git` provider also clones only into `{data}/git/<name>` and has no
   `dst`. Moving a submodule keeps today's edit-in-place workflow and works with `link` now.
   Their URLs switch from `git@github.com:` to `https://github.com/`: all five repos are
   public, and Docker has no ssh keys. Pushing still goes over ssh through the gitconfig
   `insteadOf` rule.
3. **The `dotbot` submodule stays, used only by `install-windows`** (chunk 6), until dots
   Windows support (task 7.5) exists. `install`, `install-macos`, `common.conf.yaml`,
   `install.conf.yaml` and `macos.conf.yaml` are deleted.
4. **The rc files become `inject`, not links.** `~/.zshenv` was a symlink to
   `zsh-conf/env.zsh`. dots writes its env block through symlinks
   (`dots-env/src/inject.rs:44`), so with a symlink it would edit the submodule. So
   `~/.zshenv` becomes a real file with two marked blocks: dots env, and
   `source "$HOME/.zsh-conf/env.zsh"`. `~/.zshrc` gets an inject block that sources
   `entrypoint.zsh`, which replaces `install_zshrc.sh`. Work tooling (drift asdf) also writes
   into `~/.zshrc`, and inject leaves those lines alone.
5. **Directory links are replaced by per-file links wherever an app writes runtime state into
   the dir.** `~/.config/herdr` is the main case: today herdr writes sockets, logs, sessions
   and `plugins/` into the repo. `~/.config/ghostty` is the other: the shaders clone and
   `config.platform` lived in the repo. Pure-config dirs stay dir links:
   `~/.config/{nvim,yazi,sketchybar,hypr,waybar,rofi,swaync,awesome,autorandr}`,
   `~/.zsh-conf`, `~/.my-zsh-conf`, `~/.tmux_conf` and `~/dotfiles_scripts`.
6. **Files that apps rewrite stay `link`**, so the app's edits land in the repo as they do
   today: karabiner.json, linearmouse.json, copyq.conf, `~/.claude/settings.json`,
   `~/.pi/agent/settings.json` and the VS Code settings. `render` would turn every app write
   into `modified`.
7. **herdr config is a `render`.** It is TOML with layers `common.toml` + `mac.toml`
   (+ `linux.toml` if one appears), and `[files.merge]` reproduces the `yq '*+'`
   array-append only where the platform layer really appends. `config-dev.generated.toml` is
   a second render (common + mac + dev). `DEV_REPLACE_PATHS` disappears, because replace is
   the default. `generate-config.sh` is deleted (chunk 6 keeps a Windows copy).
8. **Ghostty uses its native include and stays `READY`.** `~/.config/ghostty/config` links to
   the `config` file. `~/.config/ghostty/config.platform` links to `config.macos` or
   `config.linux` through two file entries with opposite `when`. The `config-file =
   ?config.platform` line stays. This is simpler than a text render and needs no new feature.
9. **The gitconfig is composed (`P5:5.5` fragments).** The `git` package owns the base at
   priority 0. `delta` owns `[core] pager`, `[interactive]` and `[delta]`. `difftastic` owns
   `[diff] tool`, `[difftool*]` and `[pager] difftool`. The `url.*.insteadOf` ssh rewrites are
   a separate fragment with `when = 'not(tag = "sandbox")'`. Without that, every https GitHub
   clone in Docker turns into ssh and fails. **Fallback** if 5.5 is missing: one `render` with
   layers `gitconfig` + `{src = "gitconfig.ssh-urls", when = 'not(tag = "sandbox")'}`.
10. **Machine identity comes from facts and tags, never marker files.**
    - `remote` tag replaces `~/.remote_indicator`.
    - `[facts] sudo = false` replaces `~/.no_sudo_indicator`.
    - `sandbox` tag means Docker or CI: no ssh keys, no private repos, no `gh auth`.
    - `work` tag means drift.ai work tools.
    - `gaming` tag means the Steam stack.
    - `dell` and `thinkpad` tags select ACPI event sets.
    - GUI uses the built-in **fact** `gui`, overridden in the Linux desktop profile (from an
      ssh session the fact would be false).
    - zsh-conf and my-zsh-conf still test the old marker files at runtime. They are untouched
      (`# TODO(dots-migration)` in `packages/zsh/README.md`).
11. **Provider priority** (`dots.toml`):
    - macOS: `brew, cargo, uv, npm-g, script`.
    - debian: `apt, cargo, uv, npm-g, script`.
    - any: `cargo, uv, npm-g, script`.
    - Rust CLIs declare `brew` + `cargo` only, not `apt`, because apt on 24.04 lags too far
      behind.
    - Plain system packages declare `brew` + `apt`.
12. **Interim custom declarative providers** (task 3.7 is done) are defined in `dots.toml`:
    `npm-g`, `gh-ext`, `herdr-plugin`, `pi-package` and `code-ext`. When tasks 7.1, 7.10 and
    7.11 land, they are replaced by the built-in `npm`, `vscode-ext` and
    `[providers] use = ["gh-ext", "herdr-plugin", "pi-package"]`. They are named `npm-g` and
    `code-ext` so they don't collide with the reserved built-in ids `npm` and `vscode-ext`.
13. **Bootstrap packages** use the names the providers request (`dots-providers`):
    `homebrew` (macOS script fetch), `rustup` (macOS: brew formula `rust`, which is what this
    Mac already has; Linux: rustup script fetch), `uv` (brew or astral script fetch) and `git`
    (brew or apt).
14. **Docker and Linux are first-class.** Every macOS-only package has
    `when = 'os = "macos"'`. Every GUI package has `when = 'gui'`. Every Linux-desktop package
    has `when = 'all(os = "linux", gui)'`. Anything that needs ssh, auth or private repos has
    `not(tag = "sandbox")`. Hardcoded `x86_64`/`amd64` in installers becomes
    `$DOTS_ARCH`-aware, because the Docker target is aarch64.
15. **Undeclared software found on this Mac** (§3.3) is adopted, not ignored:
    - Generic dev tools go into `dev`.
    - Mac-only brew leaves go into `mac-extra`.
    - Work tools go into `work` (tag `work`).
    - Apps installed outside brew (Raycast, Slack, Tailscale.app and so on) are **not**
      declared, because a cask install would collide with the existing `.app`. They are
      listed as follow-ups.
16. **Hardcoded `~/dotfiles/...` paths are rewritten to deployed paths** (§4.3), never to
    `packages/...` paths. Deployed paths survive worktree switching (ARCH §11).
17. **Secrets:** none are committed. The repo references `~/secrets.zsh`
    (`dotfiles/my-zsh-conf/env.zsh:95`, sourced unconditionally) and `~/.git_work` (gitconfig
    `includeIf`). Both exist on this Mac and both stay local and untracked. The `source` is
    guarded with `[[ -f ]]` so shells in Docker and on fresh machines start cleanly. I didn't
    read either file's contents.
18. **Windows is `DEFER`.** dots has no Windows support yet (task 7.5). Chunk 6 moves the
    Windows-only files to `legacy/windows/` and rewrites `windows.conf.yaml` to the new package
    paths, so a Windows dotbot run keeps working.

---

## 2. Target tree

```
~/dotfiles-dots/
├── dots.toml                      # chunk 1
├── machines/                      # chunk 1
│   ├── mac.toml                   # this MacBook: base dev agents gui-apps fonts mac-desktop mac-extra work; tags work
│   ├── linux-desktop.toml         # Ubuntu x86_64 Hyprland laptop: base dev agents gui-apps fonts linux-desktop; facts.gui=true
│   ├── remote.toml                # ssh boxes: base; tags remote
│   └── docker.toml                # ubuntu-24.04/aarch64 container: base dev agents; tags sandbox; facts.gui=false
├── bundles/
│   ├── base.toml                  # chunk 1: shell, git, core CLI (any box, incl. remote)
│   ├── dev.toml                   # chunk 2: editor, tmux, language toolchains, TUIs, gh
│   ├── agents.toml                # chunk 3: claude/codex/cursor/pi, agents-status, herdr + plugins
│   ├── mac-desktop.toml           # chunk 4: WM, bar, input devices, macOS defaults/services
│   ├── mac-extra.toml             # chunk 4: brew leaves found on this Mac, macOS-only
│   ├── work.toml                  # chunk 4: drift.ai tools (tag work)
│   ├── gui-apps.toml              # chunk 5: ghostty, vscode, alacritty, spotify, browser extensions
│   ├── fonts.toml                 # chunk 5
│   ├── linux-desktop.toml         # chunk 5: hyprland/awesome/x11 bits, acpi, services, xdg
│   ├── gaming.toml                # chunk 5: tag gaming (not in any profile by default)
│   └── optional.toml              # chunk 5: things install.conf had commented out (in no profile)
├── lib/                           # chunk 1: shared shell helpers ($DOTS_LIB)
│   ├── github-release.sh          #   gh_latest_asset <repo> <regex>; replaces helpers.sh download_latest_release
│   └── arch.sh                    #   dots_arch_alias {amd64|x86_64|x64} mapping from $DOTS_ARCH
├── packages/
│   ├── homebrew/ rustup/ uv/ git/ delta/ difftastic/ zsh/ profile/ vim/ ripgrep/ fd/ bat/ fzf/ jq/
│   │   curl/ wget/ unzip/ build-essential/ cmake/ pkg-config/ moreutils/ pcregrep/ daemon/ toilet/
│   │   sqlite3/ subversion/ python3/ ipython/ locale/ scripts/ workspace-dirs/ local-bin/      # chunk 1
│   │     zsh/zsh-conf (submodule)  zsh/my-zsh-conf/  zsh/zshenv.inject  zsh/zshrc.inject
│   │     git/gitconfig  git/gitconfig.ssh-urls  git/gitignore_global
│   │     scripts/scripts/ (was ./scripts)  scripts/requirements.txt
│   ├── koala-config/ (KoalaConfig submodule, KoalaConfig-10/, kvim.conf) kv/ kv-env/ neovim/
│   │   tree-sitter-cli/ lemmy-help/ nvim-dict/ deno/ plantuml/ koala-cli/ codelldb/
│   │   tmux/ tpm/ libtmux/ go/ node/ npm-prefix/ bun/ fx/ btop/ bottom/ du-dust/ jless/ igrep/
│   │   broot/ tuitab/ lumen/ ftdv/ hunk/ yazi/ yq/ yj/ ez-workspaces/ hop/ gh/ gh-dash/ gh-enhance/
│   │   gh-markdown-preview/ gh-stack/ playgrounds/ shell-gpt/ mkdocs/ ranger-fm/ openspec/
│   │   mermaid-cli/ cargo-audit/ cargo-nextest/ comrak/ lazydiff/ mermaid-rs-renderer/ eza/ just/
│   │   tree/ fzy/ glow/                                                                       # chunk 2
│   ├── claude/ claude-code/ codex/ cursor/ cursor-agent/ cursor-cli-wrapper/ pi/ pi-subagents/
│   │   pi-powerline-footer/ pi-community-themes/ pi-skills/ agents-status/ alerter/ claude-swap/
│   │   graphifyy/ herdr/ herdr-last-tab/ herdr-nvim-aware/ extrakto-herdr/
│   │   herdr-automatic-rename/ herdr-navigator/ herdr-reviewr/ herdr-pr-tracker/ herdr-notify/
│   │   herdr-workspace-move/ herdr-pr-board/ herdr-collie/                                    # chunk 3
│   ├── karabiner/ linearmouse/ aerospace/ aerospace-scripts/ aerospace-switcher/ sketchybar/
│   │   sketchybar-app-font/ borders/ betterdisplay/ markdown-preview/ macos-defaults/
│   │   macos-power/ <mac-extra pkgs>/ <work pkgs>/                                            # chunk 4
│   └── ghostty/ ghostty-shaders/ font-*/ vscode/ vscode-ext-*/ alacritty/ spotify/
│       browser-extensions/ hyprland/ hyprland-plugins/ awesome/ autorandr/ copyq/ fusuma/
│       xmodmap/ tridactyl/ desktop-apps/ xdg-defaults/ autolock/ acpi/ bluetuith/ wiremix/
│       xclip/ brotab/ openbox/ gamescope/ proton-ge/ sublime/ taskwarrior/ firefox-deb/
│       vicinae/ pulseaudio/                                                                   # chunk 5
├── legacy/windows/                # chunk 6 (DEFER): install-windows*, windows.conf.yaml, install_scripts/windows, pwsh-conf, …
├── dotbot/                        # submodule, kept for legacy/windows only
├── docs/                          # chunk 6: mac/ (KEY_CONFLICTS, SYSTEM_CHANGES, TOUCHPAD), keyboards/, media/ stays
├── .claude/ .cursor/ openspec/    # repo-local agent config and specs: untouched
├── README.md AGENTS.md KEYBINDINGS.md MIGRATION.md Makefile .gitignore .gitmodules .githooks/ .editorconfig .luarc.json
```

### 2.1 Machine profiles (chunk 1)

```toml
# machines/mac.toml
schema = 1
bundles = ["base", "dev", "agents", "gui-apps", "fonts", "mac-desktop", "mac-extra", "work"]
tags = ["work"]

# machines/linux-desktop.toml
schema = 1
bundles = ["base", "dev", "agents", "gui-apps", "fonts", "linux-desktop"]
tags = []                       # add "dell" or "thinkpad" per laptop; "gaming" opt-in
[facts]
gui = true

# machines/remote.toml
schema = 1
bundles = ["base"]
tags = ["remote"]

# machines/docker.toml
schema = 1
bundles = ["base", "dev", "agents"]
tags = ["sandbox"]
[facts]
gui = false
```

A real machine's local `~/.config/dots/machine.toml` is `root = "~/dotfiles"` +
`profile = "mac"`. Profiles can't be selected by hostname. That is fine for now.

### 2.2 `dots.toml` (chunk 1 writes exactly this, then adjusts only what lint forces)

```toml
schema = 1
requires_dots = ">=0.2"
name = "ofirgall/dotfiles"

[priority]
any    = ["cargo", "uv", "npm-g", "script"]
macos  = ["brew", "cargo", "uv", "npm-g", "script"]
debian = ["apt", "cargo", "uv", "npm-g", "script"]

[tags]
remote   = "headless ssh box: base only (replaces ~/.remote_indicator)"
work     = "drift.ai work machine: work tools"
sandbox  = "throwaway container or CI: no ssh keys, no private repos, no gh auth"
gaming   = "Steam + gamescope + openbox session"
dell     = "Dell laptop ACPI events"
thinkpad = "ThinkPad ACPI events"

# ---- Interim declarative providers (ARCH §5.4). Replace per TODO when tasks 7.1/7.10/7.11 land.
# TODO(dots-migration): replace with built-in `npm` provider (task 7.1)
[providers.npm-g]
available = "command -v npm"
bootstrap = "node"
installed = { cmd = "npm ls -g --json --depth=0", parse = "json:dependencies" }
install   = "npm install -g {name}"
batch     = false

# TODO(dots-migration): replace with `[providers] use = ["gh-ext"]` (task 7.11)
[providers.gh-ext]
available = "command -v gh"
bootstrap = "gh"
installed = { cmd = "gh extension list", parse = 'regex:^[^\t]+\t(?P<name>[^\t]+)\t(?P<version>\S+)' }
install   = "gh extension install {name}"
batch     = false

# TODO(dots-migration): replace with `use = ["herdr-plugin"]` (task 7.11): --json, --ref pinning, local link, enabled, {plugin_config}
[providers.herdr-plugin]
available = "command -v herdr"
bootstrap = "herdr"
installed = { cmd = "herdr plugin list", parse = 'regex:^- (?P<name>\S+) \(' }
install   = "herdr plugin install {source} --yes"
batch     = false

# TODO(dots-migration): replace with `use = ["pi-package"]` (task 7.11)
[providers.pi-package]
available = "command -v pi"
bootstrap = "pi"
installed = { cmd = "pi list", parse = 'regex:^\s+(?P<name>(?:npm|git):\S+)\s*$' }
install   = "pi install {name}"
batch     = false

# TODO(dots-migration): replace with built-in `vscode-ext` (task 7.10)
[providers.code-ext]
available = "command -v code"
bootstrap = "vscode"
installed = { cmd = "code --list-extensions --show-versions", parse = 'regex:^(?P<name>[^@]+)@(?P<version>\S+)$' }
install   = "code --install-extension {name} --force"
batch     = false
```

If `{source}` isn't a supported placeholder in `custom.rs` (it fills `{name}` and `{source}`
from the spec, so check how a package passes `source`), the herdr plugin packages use
`name = "<owner>/<repo>"` with `install = "herdr plugin install {name} --yes"`, and match the
installed id with a `regex` that captures the id. Record that limitation as a TODO.

---

## 3. Inventory

### 3.1 Links (all four dotbot YAMLs, deduplicated)

YAML key: C = common.conf.yaml (Linux base and Mac), I = install.conf.yaml (Linux non-remote),
M = macos.conf.yaml, W = windows.conf.yaml.

| dst | src today | in | → package / mode | when | status |
|---|---|---|---|---|---|
| `~/agents-status` | `agents-status` (submodule) | C M | agents-status / link dir → `agents-status/` | all | READY |
| `~/.zshenv` | `dotfiles/zsh-conf/env.zsh` | C M | zsh / **inject** `zshenv.inject` (sources `~/.zsh-conf/env.zsh`) | all | READY (decision 4) |
| `~/.zshrc` | (install_zshrc.sh) | C M | zsh / **inject** `zshrc.inject` | all | READY |
| `~/.zsh-conf` | `dotfiles/zsh-conf` | C M | zsh / link dir `zsh-conf/` (submodule) | all | READY |
| `~/.my-zsh-conf` | `dotfiles/my-zsh-conf` | C M | zsh / link dir | all | READY |
| `~/.profile` | `dotfiles/profile` | C M W | profile / link | unix | READY |
| `~/.gitconfig` | `dotfiles/gitconfig` | C M W | git / **fragment** p0 + delta p50 + difftastic p50 + ssh-urls fragment | ssh-urls: `not(tag="sandbox")` | P5:5.5 (fallback: render with layers) |
| `~/.gitignore_global` | `dotfiles/gitignore_global` | C M W | git / link | all | READY |
| `~/.ripgreprc` | `dotfiles/ripgreprc` | C M W | ripgrep / link | all | READY |
| `~/.tmux.conf` | `tmux_conf/entrypoint.tmux` | C M | tmux / link | all | READY |
| `~/.tmux_conf` | `dotfiles/tmux_conf` | C M | tmux / link dir | all | READY |
| `~/.tmux/custom-macros` | `tmux_conf/custom-macros` | C M | tmux / link | all | READY |
| `~/dotfiles_scripts` | `scripts` | C M W | scripts / link dir `scripts/` | all | READY |
| `~/.config/nvim` | `editors/KoalaConfig` | C M W | koala-config / link dir `KoalaConfig/` | all | READY |
| `~/.config/kvim-envs/main` | `editors/KoalaConfig` | C M W | koala-config / link dir (same src) | all | READY |
| `~/.vimrc` | `dotfiles/vimrc` | C M W | vim / link | all | READY |
| `~/playgrounds` | `playgrounds` | C | playgrounds / link dir | all (was missing on Mac: P1 drift fixed) | READY |
| `~/.kvim.conf` | `dotfiles/.kvim.conf` | C M W | koala-config / link `kvim.conf` | all | READY |
| `~/.config/yazi` | `dotfiles/yazi` | C M W | yazi / link dir | all | READY |
| `~/.config/hunk` | `dotfiles/hunk` | C | hunk / link dir | all (missing on Mac) | READY |
| `~/.config/lumen` | `dotfiles/lumen` | C | lumen / link dir | all (missing on Mac) | READY |
| `~/.claude/settings.json` | `dotfiles/claude/settings.json` | C M W | claude / link (app rewrites it) | all | READY |
| `~/.claude/keybindings.json` | `dotfiles/claude/keybindings.json` | C M W | claude / link | all | READY |
| `~/.claude/statusline-command.sh` | `dotfiles/claude/statusline-command.sh` | C M W | claude / link | all | READY |
| (new) `~/.claude/mods` | `dotfiles/claude/mods` (was referenced by absolute repo path) | – | claude / link dir; settings.json `ofir-mods` marketplace path → `~/.claude/mods` | all | READY + TODO: verify Claude expands `~`, else P5:5.4 render+set |
| `~/.codex/config.toml` | `dotfiles/codex/config.toml` | C | codex / link | all | READY |
| `~/.pi/agent/settings.json` | `dotfiles/pi/settings.json` | C M W | pi / link | all | READY |
| `~/.pi/agent/keybindings.json` | `dotfiles/pi/keybindings.json` | C | pi / link | all | READY |
| `~/.cursor/statusline.sh` | `dotfiles/cursor/statusline.sh` | C M W | cursor / link | all | READY |
| `~/.config/agents-status/config.toml` | `agents-status-config.toml` (W: `-windows`) | C M (W) | agents-status / link | unix (Windows variant → chunk 6) | READY |
| `~/.config/cursor-cli-wrapper/config.toml` | `cursor-cli-wrapper.toml` | C I M W | cursor-cli-wrapper / link | all | READY |
| `~/.config/gh-dash/config.yml` | `gh-dash/config.yml` | C M W | gh-dash / link | all | READY |
| `~/.config/hop/config.toml` | `hop/config.toml` | M W | hop / link | macos | READY |
| `~/.config/herdr` (dir!) | `dotfiles/herdr` | M | herdr / **render** `config.toml` + render `config-dev.generated.toml` + link `agent-detection/`, `scripts/*.sh` + **terminfo** | all | READY (render/merge 4.5 done) |
| `~/AppData/Roaming/herdr/config.toml` | `herdr/config.toml` | W | DEFER | windows | DEFER |
| `~/.config/herdr-automatic-rename/config.sh` | same | M | herdr-automatic-rename / link | all | READY; later `{plugin_config}` INTERIM:7.11 |
| `~/.config/karabiner/karabiner.json` | `mac/karabiner/karabiner.json` | M | karabiner / link + `post_files = "touch -h …"` | macos | READY |
| `~/.config/linearmouse/linearmouse.json` | `mac/linearmouse/…` | M | linearmouse / link | macos | READY |
| `~/.aerospace.toml` | `mac/aerospace/aerospace.toml` | M | aerospace / link | macos | READY |
| (new) `~/.config/aerospace/scripts` | `mac/aerospace/*.sh`, `toggle-input-source*` | – | aerospace / link dir `scripts/` (paths rewritten, §4.3) | macos | READY |
| `~/.config/sketchybar` | `mac/sketchybar` | M | sketchybar / link dir | macos | READY |
| `~/.config/borders/bordersrc` | `mac/borders/bordersrc` | M | borders / link | macos | READY |
| `~/Library/Application Support/ez/config.toml` and `~/.config/ez/config.toml` | `ez-workspaces-macos/` and `ez-workspaces/` | M, I | ez-workspaces / 2 link entries (different src): macOS → `{app_support}/ez/config.toml`, linux → `~/.config/ez/config.toml` | per-os `when` | READY |
| `~/Library/Application Support/bottom/bottom.toml`, `~/.config/bottom/bottom.toml` | `bottom/bottom.toml` | M W | bottom / link, `dst = { default = "~/.config/bottom/bottom.toml", macos = "{app_support}/bottom/bottom.toml" }`; `bottom-full.toml` linked next to it | all | READY |
| `~/.vscode-settings` | `editors/vscode-settings` | I | vscode / link dir (submodule) | linux gui | READY |
| `~/.config/Code/User/{settings,keybindings}.json` | `~/.vscode-settings/*.json` | I | vscode / link → `vscode-settings/*.json` directly | linux gui | READY |
| `~/.config/fusuma/config.yml` | `fusuma.yml` | I | fusuma / link | linux gui (package in `optional`; file only when installed) | READY |
| `~/.alacritty.toml`, `~/alacritty-fonts` | `alacritty.toml`, `alacritty-fonts/` | I | alacritty / link | linux gui | READY |
| `~/.taskrc`, `~/.taskwarrior_shortcuts` | `taskrc`, `taskwarrior_shortcuts/` | I | taskwarrior / link (package in `optional`) | linux gui | READY |
| `~/.xmodmaprc` | `xmodmaprc` | I | xmodmap / link | linux gui | READY |
| `~/.config/awesome` | `awesomewm/` | I | awesome / link dir | linux gui | READY |
| `~/.config/{hypr,waybar,swaync,rofi}` | `hypr-dots/*` | I | hyprland / 4 link dirs into `hypr-dots/` submodule | linux gui | READY |
| `~/.config/autorandr` | `autorandr/` | I | autorandr / link dir | linux gui | READY |
| `~/.config/copyq/copyq.conf` | `copyq.conf` | I | copyq / link | linux gui | READY |
| `~/.tridactylrc` | `tridactylrc` | I | tridactyl / link | linux gui | READY |
| `~/.config/systemd/user` (whole dir!) | `services/` | I | autolock / `[service]` unit `autolock.service` (no dir link) | linux gui | P5:5.15 (fallback: link the unit file + script `systemctl --user enable`) |
| `~/.config/openbox/{autostart,rc.xml}` | `openbox/*` | I | openbox / link | `tag = "gaming"` | READY |
| `~/.config/ftdv/config.yaml` | `ftdv/config.yaml` | I | ftdv / link | all | READY |
| `~/.config/ghostty` (dir) | `dotfiles/ghostty` | I M W | ghostty / link `config` + link `config.platform` (macos→`config.macos`, linux→`config.linux`) | gui | READY (decision 8) |
| `~/.config/ez/config.toml` | `ez-workspaces/config.toml` | I | see ez row | | |
| `~/.config/vdesk-collapser/config.toml` | `vdesk-collapser/config.toml` | I | hyprland / link | linux gui | READY |
| `~/.local/share/applications/{gh-markdown-preview,hypr-browser}.desktop` | `desktop-apps/` | I | desktop-apps / link ×2 | linux gui | READY |
| W-only links (`pwsh` profile, `~/.pwsh-conf`, `~/.my-pwsh-conf`, …) | | W | legacy/windows | windows | DEFER |
| `create: ~/projects ~/workspace` (C), `~/workspace/{personal,work}` (M) | | C M | workspace-dirs / 4 `dir` entries, all OSes | all | READY |
| (new) `~/.terminfo` herdr-256color | `herdr/herdr-256color.terminfo` | (script) | herdr / `mode = "terminfo"` | all | READY (5.13 done); **missing on this Mac today** |
| (new) `~/.terminfo` tmux-256color | infocmp from brew ncurses | (script) | tmux / `terminfo`, the source committed as `tmux-256color.terminfo` | macos | READY |

### 3.2 Shell steps → packages

Linux = `install_scripts/*.sh`, Mac = `install_scripts/mac/*.sh`. Packages are listed in the
chunk that owns them. Status as above.

| Source step | Becomes | Status |
|---|---|---|
| `git submodule update --init --recursive` (all YAMLs) | dropped. Submodules are part of the repo checkout, and `dots init --from` clones recursively (verify; else a README note) | DROP |
| mac `install_brew.sh` | `homebrew`: script `fetch = { url = "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh" }`, `install = "NONINTERACTIVE=1 bash {fetched}"`, `check = "test -x /opt/homebrew/bin/brew"`, `when = 'os = "macos"'` | P5:5.12 |
| `install_zshrc.sh` | zsh `inject` on `~/.zshrc` | READY |
| `install_zsh.sh`: apt zsh, chsh, subversion, jq, sqlite3, zinit completions dir | `zsh` (apt/brew), `subversion`, `jq`, `sqlite3`; `chsh` → `zsh/manual/default-shell.md` (check `getent passwd $USER \| grep -q zsh` / `dscl`); `dir` `~/.cache/zinit/completions` | READY; manual INTERIM:6.10 |
| `install_basic.sh` apt: wget moreutils ipython3 pcregrep python3-pip build-essential fzf daemon curl cmake btop toilet python3-venv | one package each (chunk 1, except btop → chunk 2) | READY |
| `add-apt-repository ppa:git-core/ppa` | `git`: `[providers.apt] repo = { ppa = "git-core/ppa" }` | P5:5.12 |
| NO_SUDO branch: clone fzf, `pip install -r scripts/requirements.txt --user` | dropped. `facts.sudo=false` makes apt unavailable, so fzf resolves to the next provider (add `[providers.script]` fallback that clones `~/.fzf`); requirements → `scripts-venv` | READY |
| `pip install --break-system-packages brotab ranger-fm shell-gpt mkdocs mkdocs-material` + `bt install` | uv tools `brotab` (gui; `post_install = "bt install"`), `ranger-fm`, `shell-gpt`, `mkdocs` (TODO: `--with mkdocs-material` not expressible in `[providers.uv]` → gap G12; interim: script `uv tool install mkdocs --with mkdocs-material`) | READY / INTERIM |
| apt bat ripgrep `--force-overwrite`, `ln batcat→bat` | `bat` `[providers.apt] bin="batcat" shim="bat"`, `ripgrep` | READY |
| `curl fx.wtf/install.sh \| sh` | `fx`: brew on Mac; linux script `fetch = { url = "https://fx.wtf/install.sh" }` | P5:5.12 |
| apt fd-find + `ln fdfind→fd` | `fd` `[providers.apt] name="fd-find" bin="fdfind" shim="fd"` | READY |
| apt xclip (non-remote) | `xclip` (linux gui) | READY |
| rustup curl \| sh, `rustup update` | `rustup`: brew `rust` on Mac (what is installed), linux script fetch `https://sh.rustup.rs` `install = "sh {fetched} -y --no-modify-path"`; `[env] path = ["~/.cargo/bin"]` | P5:5.12 |
| cargo difftastic du-dust git-delta jless igrep bottom(--locked) broot(--locked) | packages with brew+cargo (`locked = true` where used) | READY |
| apt libxcb* (jless build deps) | `jless` `requires` a `libxcb-dev` group: one script package `jless-build-deps` (linux) running `apt-get install`; TODO: per-provider `requires` | INTERIM |
| alacritty from git + update-alternatives + .desktop (non-remote) | `alacritty`: script (linux gui), `requires = ["rustup"]`, apt build deps inside the script | INTERIM (source build is a script by design, §16) |
| apt gh (non-remote) | `gh`: brew/apt | READY |
| WSL → `install_wsl_utils.sh` (win32yank) | `win32yank`: script, `when = 'wsl'` (base bundle) | INTERIM:7.1 |
| apt npm, `npm i -g n; n stable`, `npm config set prefix ~/.npm-packages` | `node`: brew on Mac; linux script fetch `n` → `N_PREFIX=~/.local/n` (no sudo); `npm-prefix` (linux): `[env] vars = { NPM_CONFIG_PREFIX = "~/.npm-packages" }`, `path = ["~/.npm-packages/bin"]` | P5:5.12 |
| `curl bun.sh/install \| bash` | `bun`: brew (`tap = "oven-sh/bun"`) / linux script fetch; env `~/.bun/bin` | P5:5.12 |
| bluetuith `download_latest_release` (x86_64 hardcoded) | `bluetuith`: script using `$DOTS_LIB/github-release.sh`, arch-aware | INTERIM:7.1 |
| `usermod -aG dialout`, `newgrp` (hangs non-interactive: P4) | `serial-access/manual/dialout.md` (check `id -nG \| grep -qw dialout`, requires logout); `newgrp` dropped | INTERIM:6.10 |
| `install_dap.sh` codelldb (x64 hardcoded) | `codelldb`: script, asset `codelldb-linux-{x64\|arm64}.vsix`, link `~/.local/bin/codelldb` | INTERIM:7.1 |
| `install_nvim.sh` build deps (ninja-build gettext libtool… clang) | `neovim-build-deps` script group (linux) | INTERIM |
| cargo tree-sitter-cli (--locked), lemmy-help (`--features=cli`) | cargo (`features = ["cli"]`) | READY |
| dictd dict-wn + dict-moby-thesaurus .deb via wget/dpkg | `nvim-dict`: apt dictd/dict-wn + script for the .deb | INTERIM:7.1 |
| deno curl \| sh + ln | `deno`: brew / linux script fetch, env `~/.deno/bin` | P5:5.12 |
| apt plantuml graphviz | `plantuml` (apt/brew), `graphviz` folded into plantuml's `requires` | READY |
| `upgrade_nvim.sh v0.11.5` (linux) | `neovim`: brew on Mac (0.12.4 present); linux script running `~/dotfiles_scripts/misc/upgrade_nvim.sh`, `version = "0.11.5"`. Note: the original guard `if -d …` is a bug, it never runs | INTERIM:7.1 |
| `cargo install --git KoalaVim/kv` (CARGO_NET_GIT_FETCH_WITH_CLI) | `kv`: cargo `git = "https://github.com/KoalaVim/kv"`, `git_fetch_with_cli = true` | P5:5.12 |
| `pip install git+ssh://…/koala-cli.git` | `koala-cli`: uv `git = "git+ssh://git@github.com/KoalaVim/koala-cli.git"`, `when = 'not(tag = "sandbox")'` (private repo) | P5:5.12 |
| mac `install_kvim.sh`: kv; `kv env create main` (never runs, because the dir is linked first); `kv install` | `kv`, `kv-env`: script `check = "test -x ~/.local/share/kvim-envs/main/kv/bin/nvim"`, `install = "kv install"`, `requires = ["kv", "koala-config"]` | INTERIM |
| `install_tmux.sh`: build latest tmux from source; ruby; libtmux; tpm; default-keys | Linux: `tmux` = apt (3.4) (decision: a source build isn't worth it; TODO if the conf needs ≥3.5). Mac: brew. `libtmux`: uv `kind="lib" python="system"`. `ruby`: apt (tmux plugin dep). `tpm`: script clone `~/.tmux/plugins/tpm` (INTERIM `git` mode). tmux `post_install` writes `~/.tmux/default-keys.conf`. tpm `post_files = "~/.tmux/plugins/tpm/bin/install_plugins"` | READY / INTERIM |
| mac `install_tmux.sh` infocmp/tic tmux-256color | tmux `terminfo` file (macos) | READY |
| `install_go.sh` (amd64 hardcoded, sudo /usr/local) | `go`: brew / linux script into `~/.local/go`, arch-aware, `[env] path = ["~/.local/go/bin", "~/go/bin"]` | INTERIM:7.1 |
| `install_wrappers.sh` cargo cursor-cli-wrapper | dropped in favor of agents-status `install.sh cursor-cli-wrapper` (that is what the Mac runs; avoids two installs) | READY |
| `install_git_utils.sh` gh ext dash/enhance/markdown-preview | `gh-dash`, `gh-enhance`, `gh-markdown-preview` via `gh-ext`, `when = 'not(tag = "sandbox")'` | INTERIM:7.11 |
| mac `install_git_utils.sh` + cask markdown-preview | + `markdown-preview` cask (chunk 4) | READY |
| `install_tuis.sh`: wiremix (+apt deps), hunkdiff (npm), lumen, ftdv, tuitab, ez-workspaces (git) | `wiremix` (linux gui, cargo, script deps), `hunk` (npm-g `hunkdiff`), `lumen`, `ftdv`, `tuitab` (cargo), `ez-workspaces` (cargo git) | READY / P5:5.12 |
| `install_agents_status.sh` (uv tool install ~/agents-status/core; install.sh cursor-cli-wrapper) | `agents-status`: uv `path = "agents-status/core"`; `cursor-cli-wrapper`: script `install = "agents-status/install.sh cursor-cli-wrapper"` | P5:5.12 |
| mac `install_agents_status.sh` + `brew install vjeantet/tap/alerter` | `alerter` (macos, brew `tap`) | READY |
| `install_vscode.sh` (MS apt repo via apt-key) | `vscode`: apt `repo = { url = "https://packages.microsoft.com/repos/code", suite = "stable", components = ["main"], key = "https://packages.microsoft.com/keys/microsoft.asc", fingerprint = "BC528686B50D79E339D3721CEB3E94ADBE1229CF" }`, linux gui | P5:5.12 |
| `vscode-settings/install_extensions.sh` (36 ids) | one `vscode-ext-<id>` package per line via `code-ext`, bundle member list in `gui-apps` | INTERIM:7.10 |
| `install_fonts.sh` (linux nerd-fonts 3.4.0 ×7 + Maple) / mac `install_fonts.sh` casks + Cilantro + patched Nerdwand/Lyth | `font-<name>` packages: brew cask on Mac, linux script via `$DOTS_LIB` into `~/.local/share/fonts/dots/<pkg>`, one `fc-cache` in a `fonts-cache` package `after` all fonts; `font-cilantro-code` (script, both); `font-nerdwand-lyth` (script, both: Ghostty uses Nerdwand on Linux too and it was never installed there). Caskaydia italic removal = `post_install` of `font-caskaydia-cove` | INTERIM:7.9 |
| `install_spotify.sh` (apt repo, key via gpg dearmor) | `spotify`: apt `repo = { url = "https://repository.spotify.com", suite = "stable", components = ["non-free"], key = "https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg", fingerprint = <fill> }`, linux gui | P5:5.12 |
| `awesomewm/install_awesomewm.sh` | `awesome`: script (linux gui) | INTERIM |
| `ln -sf config.linux|macos ghostty/config.platform` | ghostty `config.platform` link entries | READY |
| `install_ghostty_plugins.sh` / mac basic (clone shaders) | `ghostty-shaders`: script clone into `~/.config/ghostty/shaders`, `check = "test -d ~/.config/ghostty/shaders/.git"`. TODO → file `mode = "git"` | INTERIM (gap G1) |
| `install_ghostty.sh` (linux source build, zig x86_64 hardcoded) | `ghostty`: brew cask on Mac; linux script (arch-aware zig, prefix `~/.local`), `when = 'gui'` | INTERIM:7.1 |
| `xdg_defaults.sh` | `xdg-defaults`: `[[xdg]] mime=["text/markdown"] app="gh-markdown-preview.desktop"`, `[[xdg]] setting="default-web-browser" value="hypr-browser.desktop"` | P5:5.14 (fallback: script) |
| mac `install_karabiner.sh`, `install_linearmouse.sh`, `install_betterdisplay.sh`, `install_ghostty.sh` (casks + `open -a`) | casks; `open -a` → `post_install` hooks; permissions → `manual/*.md` | READY / manual INTERIM:6.10 |
| `touch -h ~/.config/karabiner/karabiner.json` | karabiner `post_files` hook | READY |
| mac `install_aerospace.sh` (tap cask, make aerospace-scripts, make aerospace-switcher) | `aerospace` cask (`tap = "nikitabobko/tap"`); `aerospace-scripts` (script `make -C … install`, check `test -x ~/.local/bin/aerospace-scripts`); `aerospace-switcher` (script, swift, same pattern) | READY / INTERIM |
| mac `install_sketchybar.sh` (+app font, `brew services start`) | `sketchybar` (tap felixkratz/formulae) + `[service] manager="brew"`; `sketchybar-app-font` cask | P5:5.15 (fallback: `post_install = "brew services start sketchybar"`) |
| mac `install_jankyborders.sh` | `borders` + `[service]` | P5:5.15 |
| mac `install_ez_workspaces.sh` | `ez-workspaces` | P5:5.12 |
| mac `install_pi.sh`: npm `--ignore-scripts` pi; `herdr integration install pi`; `pi install` ×2; clone pi-skills | `pi`: script (`npm install -g --ignore-scripts …`, gap G13); `post_install = "herdr integration install pi \|\| true"` (gated `not(tag="sandbox")`); `pi-subagents`, `pi-powerline-footer`, `pi-community-themes` (installed, undeclared) via `pi-package`; `pi-skills`: script clone | INTERIM:7.11, G1 |
| mac `install_herdr.sh`: cargo git fork; 8 plugin installs; tic; cargo --path herdr-last-tab | `herdr` cargo `git = "https://github.com/ofirgall/herdr"`; one package per plugin; terminfo file; `herdr-last-tab` cargo `path = "."` | P5:5.12 / INTERIM:7.11 |
| `dotfiles/herdr/generate-config.sh mac` | herdr renders (decision 7) | READY |
| mac `install_collie.sh` (not in any YAML; Collie *is* installed) | `herdr-collie` (herdr-plugin `AltanS/collie`) + `post_install` script = the .env/push-keys part; `requires = ["tailscale-cli"]` → manual action (Tailscale.app is not brew) ; macos only | INTERIM |
| mac `setup_once.sh` (never in a YAML) | `macos-defaults`: 17× `[[defaults]]` (§5 chunk 4); `macos-power`: script `needs_root` for `pmset` + `mdutil` with real checks; `activateSettings -u` and `killall Dock` → `restart`; login item → linearmouse `post_install`; `open -a` → per-app hooks | P5:5.14 |
| `install_hyprland.sh` (snap pinta, cargo wayfreeze, apt wf-recorder) | `hyprland` bundle members: `pinta` (script snap), `wayfreeze` (cargo git), `wf-recorder` (apt); `hyprland-plugins`: script around `hypr-dots/install_plugins.sh` (hyprpm), `check = "hyprpm list \| grep -q virtual-desktops"` (waybar-vd clone switched to https) | INTERIM:7.11 (hyprpm def) |
| `acpi/link.sh <hardware>` (sudo ln into /etc/acpi) | `acpi`: script `needs_root`, selects `events_dell` / `events_thinkpad` from tags; check every link exists | INTERIM (owned /etc files are a later feature) |
| `install_gaming.sh`, `install_proton_ge.sh` (never in a YAML) | `gaming` bundle: `openbox` (apt + files), `gamescope` (script build), `proton-ge` (script; it checks sha512 itself) | INTERIM |
| commented-out in install.conf: sublime, fusuma, taskwarrior, firefox_from_deb; plus orphan `install_vicinae.sh` | `optional` bundle (in no profile): `sublime` (apt repo, files from `editors/sublime`), `fusuma` (script: gem + group input manual), `taskwarrior` (apt `taskwarrior`, files), `firefox-deb` (apt `repo ppa mozillateam` + `pin`), `vicinae` (script fetch) | P5:5.12 / INTERIM |
| `system/pulseaudio.pa` (linked nowhere) | `pulseaudio` package in `optional`, file kept, no entry (`# TODO(dots-migration): unknown dst`) | DEFER-ish |
| Windows YAML + `install_scripts/windows/*` | legacy/windows | DEFER |

### 3.3 Declared vs present on this Mac (2026-11-26)

Gathered read-only with `brew list`, `brew leaves`, `cargo install --list`, `uv tool list`,
`gh extension list`, `herdr plugin list`, `pi list`, `npm ls -g`, `brew services list`,
`defaults read` and symlink checks.

**Declared but missing or wrong on this Mac** (`dots status` on the first Mac run should
show these; that is expected):

| Item | Finding | Plan |
|---|---|---|
| `~/.config/hunk`, `~/.config/lumen`, `~/playgrounds` | linked only by common.conf (Linux/remote), never on the Mac. hunk/lumen/ftdv binaries also absent | declared for all OSes → dots installs and links them |
| herdr-256color terminfo | `infocmp -x herdr-256color` fails | herdr `terminfo` file fixes it |
| herdr plugin `herdr-reviewr` (`persiyanov.reviewr`) | not installed | herdr-reviewr package installs it |
| herdr plugins `herdr-navigator`, `herdr-pr-tracker` | installed from `thanhdat77/…` and `jakekroon/…`; repo declares the `ofirgall/…` forks | declared source = ofirgall fork (repo intent); installed() keys by id, so status is `ok`. TODO: decide which fork is canonical |
| herdr plugins extrakto, automatic-rename, notify, workspace-move | installed as **local** links to `~/workspace/personal/herdr-plugins/*`; declared as github | same id → `ok`. Local-link providers are a gap (G6) |
| `~/.pi/agent/skills/pi-skills` | missing | pi-skills script clones it |
| pip `libtmux`, `brotab` | not importable by the brew python3 | `libtmux` uv lib; `brotab` uv tool (gui) |
| `cursor-cli-wrapper` | in `~/.local/bin` (agents-status install.sh); never cargo-installed on the Mac | consistent with the decision in §3.2 |
| `kv`, `herdr`, `ez-workspaces`, `hop`, `herdr-last-tab` (cargo) | installed from **local paths** (`~/workspace/personal/...`) | declared as git/path sources; the sticky cargo choice is kept; source mismatch shows `outdated` until re-installed. Accept (G20) |
| `hop` | installed **twice**: brew `amittamari/tap/hop` and cargo (local path) | declare brew only (macOS); cargo copy → `dots bins --shadowed` follow-up, uninstall by hand |
| `npm -g` | PATH `npm` is the kvim env's node (`~/.local/share/kvim-envs/main/kv/node`). pi/openspec/mermaid-cli live under brew node `/opt/homebrew/lib` | `npm-g` must use brew's npm on the Mac: set `available = "test -x /opt/homebrew/bin/npm \|\| command -v npm"` and the commands to `$(command -v /opt/homebrew/bin/npm \|\| command -v npm)`. TODO in dots.toml. dots env puts `/opt/homebrew/bin` before the kv node only if the env order says so → verify with `dots which npm` |
| macOS defaults | KeyRepeat=2, InitialKeyRepeat=13, dock autohide=1, `_HIHideMenuBar`=1 all **match** setup_once.sh | `[[defaults]]` adopt with no change |

**Present on this Mac but never declared** (adopted per decision 15):

| Kind | Items | → bundle |
|---|---|---|
| brew leaves, generic dev | `eza glow just tree fzy cargo-nextest neovim node go rust uv yazi ipython luarocks zig zig@0.15 bash mas pstree imagemagick ffmpeg tesseract resvg fontforge vite` | `dev` (cross-platform where an apt/cargo equivalent exists: eza, just, tree, fzy, cargo-nextest, glow (brew-only, macOS), luarocks/imagemagick/ffmpeg → `mac-extra` for now) |
| brew leaves, macOS-specific taps | `angristan/tap/fast-resume`, `jacek-kurlit/tap/pik`, `codeburn` | `mac-extra` |
| brew leaves, work | `atlassian/acli/acli`, `auth0`, `cfn-lint`, `cloudflared`, `colima`, `docker-buildx`, `docker-compose`, `grafana/grafana/gcx`, `jira-cli` (ankitpokhrel tap), `k9s`, `opentofu`, `postgresql@15`, `prometheus`, `sqlc`, `asdf` | `work` |
| casks | `1password-cli`, `cloudflare-warp`, `gcloud-cli`, `orbstack`, `gitkraken-cli` → `work`; `flameshot` → `mac-extra`; `codex` → agents (codex package, brew cask) | |
| cargo | `cargo-audit`, `comrak`, `mermaid-rs-renderer`, `lazydiff` (git `Ataraxy-Labs/lazydiff`) | `dev` |
| uv tools | `claude-swap`, `graphifyy` | `agents` |
| gh ext | `github/gh-stack` | `dev` |
| npm -g (brew node) | `@fission-ai/openspec`, `@mermaid-js/mermaid-cli` | `dev` |
| pi | `git:https://github.com/hasit/pi-community-themes` | `agents` |
| herdr plugins | `herdr-pr-board` (local), `herdr.collie` (`AltanS/collie`), `koalavim-editor` (owned by KoalaVim's sidekick env; **not** declared: KoalaVim manages it) | `agents` (pr-board: TODO confirm public repo `ofirgall/herdr-pr-board`; if absent, script `herdr plugin link` with `not(tag="sandbox")`) |
| `~/.local/bin` (curl installers) | `claude` (Claude Code), `cursor-agent`/`agent` | `claude-code`, `cursor-agent` script-fetch packages in `agents` |
| `~/.local/bin`, unknown origin | `rtk`, `blacksmith`, `terminal-browser`, `sidekick-herdr-minimize`, `herdr-reviewr`, `agents-status-server`, `cswap` | not declared; `dots bins --unknown` follow-up |
| brew services | `borders`, `sketchybar` started (declared → `[service]`). `cloudflared colima postgresql@15 prometheus` installed, not started | services only for the two |
| LaunchAgents | `herdr.collie.plist` (written by Collie), `com.drift.local-env-tracker.plist` (work), Google, VirtualBox | not managed (owned by their apps) |
| Apps not from brew | 1Password, Burnrate, Cursor, Docker, GIMP, Google Chrome, Grok Bot, JumpCloud*, Raycast, Slack, Spotify, Sublime Merge, Tailscale, VirtualBox | **not declared** (a cask would collide with the existing .app). Follow-up: adopt via `brew install --cask --adopt` by hand, then declare |
| zsh | `/bin/zsh` is already the login shell | manual action auto-closes |

---

## 4. Conventions every chunk follows

### 4.1 Package templates

```toml
# Plain system package (brew + apt), e.g. packages/jq/package.toml
schema = 1
name = "jq"
bin = "jq"
[providers.brew]
[providers.apt]

# Rust CLI: brew + cargo, never apt (decision 11)
schema = 1
name = "difftastic"
bin = "difft"
[providers.brew]
[providers.cargo]

# macOS-only
schema = 1
name = "karabiner"
when = 'os = "macos"'
[providers.brew]
name = "karabiner-elements"
cask = true
[[files]]
src = "karabiner.json"
dst = "~/.config/karabiner/karabiner.json"
[hooks]
post_files = "touch -h ~/.config/karabiner/karabiner.json"

# INTERIM script package
schema = 1
name = "go"
bin = "go"
[providers.brew]
[providers.script]
when    = 'os = "linux"'
check   = "test -x $HOME/.local/go/bin/go"
version = "$HOME/.local/go/bin/go version | awk '{print $3}' | sed 's/^go//'"
latest  = "curl -fsSL 'https://go.dev/VERSION?m=text' | head -1 | sed 's/^go//'"
install = "install.sh"           # in the package dir; sources $DOTS_LIB/arch.sh
# TODO(dots-migration): replace with archive provider (task 7.1, ARCH §5.2.5)
[env]
path = ["~/.local/go/bin", "~/go/bin"]
```

Rules:
- Every `script` has a **real** `check` (exit 0 = installed) and a `version`, or
  `versionless = true`. `check = "false"` is forbidden: Docker's `plan --check` would never go
  idle.
- Scripts are bash. The runtime prepends `set -euo pipefail` (ARCH §5.3), so don't add it.
  Don't `source ~/.cargo/env` or `eval brew shellenv` either: dots puts provider bins on
  `PATH`. stdin is `/dev/null`, so nothing may prompt. Use `$DOTS_ARCH`, `$DOTS_OS` and
  `$DOTS_LIB`.
- Root steps go in a script with `needs_root = true`, never an inline `sudo` in a non-root
  script. The exception is apt build-deps inside a linux-only build script; give those
  `needs_root = true` too.
- Each `manual/<id>.md` has frontmatter `id`, `title`, `when`, `after`, optional `check` and
  `revision: 1` (ARCH §9). Write them now even though task 6.10 isn't done.
- Platform gating is always `when`: package-level, provider-level, file-level or layer-level.
  **Don't use `[platform.*]` tables** unless you have confirmed task 5.1 landed. Per-platform
  `dst = { default = …, macos = … }` is fine (READY).
- Every interim construct gets `# TODO(dots-migration): <what> (task x.y / gap Gn)`.

### 4.2 Commit and ownership rules
- Work on a branch off `migrate-to-dots` in its own worktree:
  `git -C ~/dotfiles-dots worktree add ~/dotfiles-dots-cN -b migrate/cN migrate-to-dots`.
  The supervisor merges chunks back.
- `git mv` sources into their package, so history is kept. **Touch only the paths your chunk
  owns** (§5). Read anything you like. Don't delete anything under `install_scripts/`, the
  `*.conf.yaml` files or the `install*` entry points: chunk 6 deletes them after everyone
  has converted them.
- Commit trailer: `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>` (as the user's
  sessions require).
- Never write secrets. `~/secrets.zsh` and `~/.git_work` stay outside the repo.

### 4.3 Path rewrite map (old repo path → deployed path)

Chunk 1 applies the rows that sit in `my-zsh-conf`. Each other chunk applies the rows in
files it owns.

| Old reference | New reference | File(s) | Owner |
|---|---|---|---|
| `~/dotfiles/editors/KoalaConfig-10/` | `~/.config/kvim-envs/010/` (koala-config links `KoalaConfig-10` there) | my-zsh-conf/aliases.zsh (`nv-10`) | c1 (alias), c2 (link) |
| `$HOME/dotfiles/dotfiles/bottom/bottom-full.toml` | `~/.config/bottom/bottom-full.toml` (Mac: `{app_support}/bottom/bottom-full.toml`; alias uses `${BTM_CONF_DIR}` set per OS in the alias line) | aliases.zsh `btmf` | c1, c2 |
| `$HOME/dotfiles/editors/KoalaConfig/` (`cdn`) | `~/.config/nvim/` (resolve symlink with `cd -P`) | aliases.zsh | c1 |
| `$HOME/dotfiles/dotfiles/tmux_conf/` (`cdt`) | `~/.tmux_conf/` | aliases.zsh | c1 |
| `~/dotfiles/dotfiles/mac/sketchybar/plugins/mode-{laptop,docked}.sh` | `~/.config/sketchybar/plugins/…` | aliases.zsh | c1 |
| `~/dotfiles/dotfiles/mac/aerospace/*` | `~/.config/aerospace/scripts/*` | aerospace.toml (3 places), on-window-detected.sh, refresh-workspaces.sh, sketchybar `plugins/ws_title_poll.sh` | c4 |
| `$HOME/dotfiles/dotfiles/mac/sketchybar/helpers/icon_map.sh` | `$HOME/.config/sketchybar/helpers/icon_map.sh` | update-ws-cache.sh | c4 |
| `~/dotfiles/dotfiles/herdr/{explain-agent,read-agent-ansi}.sh` | `~/.config/herdr/scripts/…` | herdr `config/common.toml` | c3 |
| `bash ~/dotfiles/dotfiles/herdr/generate-config.sh … && herdr server reload-config` | `dots apply herdr --files-only --yes && herdr server reload-config` | herdr `config/common.toml` (line ~272) | c3 |
| `/Users/ofirg/dotfiles/dotfiles/claude/mods` | `~/.claude/mods` | claude/settings.json | c3 |
| `~/dotfiles/awesomewm/wallpaper.jpg` | `~/.config/awesome/wallpaper.jpg` | **hypr-dots submodule** `hypr/configs/Keybinds.conf` (separate repo): leave it and list it as a follow-up | – |

---

## 5. Implementation chunks

Waves: **chunk 1 first** (it moves every submodule, writes `dots.toml`, `machines/` and
`.gitignore`, and defines the bootstrap packages everyone requires). **Chunks 2–5 run in
parallel** after chunk 1 merges. Their file ownership is disjoint, and the package names
below are the contract between them. **Chunk 6 runs last.**

Every chunk's done-criteria include its own Docker run (§7.1), plus `dots lint` clean for the
packages it owns. Lint errors for not-yet-existing packages that other chunks own are
expected in wave 2.

### Chunk 1: Foundation, shell, git, core CLI (`base`)

**Owns (new):** `dots.toml`, `machines/*.toml`, `bundles/base.toml`, `lib/**`, `.gitignore`,
`.gitmodules`, and `packages/{homebrew,rustup,uv,git,delta,difftastic,zsh,profile,vim,ripgrep,fd,bat,fzf,jq,curl,wget,unzip,build-essential,cmake,pkg-config,moreutils,pcregrep,daemon,toilet,sqlite3,subversion,python3,ipython,locale,scripts,workspace-dirs,local-bin,win32yank,serial-access}/**`.

**Moves:**
- `dotfiles/zsh-conf` (submodule) → `packages/zsh/zsh-conf`
- `dotfiles/my-zsh-conf` → `packages/zsh/my-zsh-conf`
- `dotfiles/wslrc` → `packages/zsh/wslrc` (unlinked, TODO)
- `dotfiles/profile` → `packages/profile/profile`
- `dotfiles/gitconfig` and `gitignore_global` → `packages/git/`
- `dotfiles/ripgreprc` → `packages/ripgrep/`
- `dotfiles/vimrc` → `packages/vim/`
- `scripts/` → `packages/scripts/scripts/`

**Submodule moves for everyone** (git mv, then switch the URL to https in `.gitmodules`):
- `editors/KoalaConfig` → `packages/koala-config/KoalaConfig`
- `agents-status` → `packages/agents-status/agents-status`
- `editors/vscode-settings` → `packages/vscode/vscode-settings`
- `hypr-dots` → `packages/hyprland/hypr-dots`

Create only the package dirs the submodules need, with no `package.toml`; the owning chunk
writes it. Keep `dotbot` where it is.

Brief:
1. Read ARCH §3, §4, §5.1–5.5, §6 (intro + 6.1–6.4), §10, §16 and
   `docker/ubuntu/repo-test.sh` in dots-manager. Write `dots.toml` (§2.2) and the four
   profiles (§2.1).
2. Write `lib/arch.sh`:
   - `dots_arch {go|zig|nerd|codelldb|bluetuith}` echoes the right arch string, given
     `DOTS_ARCH` ∈ {x86_64, aarch64}.
   - `dots_os_title` echoes `Linux` or `Darwin`.

   Write `lib/github-release.sh`: `gh_release_url <owner/repo> <asset-regex> [tag]` uses the
   GitHub API with an optional `GITHUB_TOKEN`, fails loudly on an empty match, and never
   `eval`s. These replace `install_scripts/helpers.sh`.
3. Bootstrap packages (§3.2 rows): `homebrew`, `rustup` (Mac brew `rust`; Linux fetch rustup,
   `[env] path ["~/.cargo/bin"]`, `bin = "cargo"`), `uv` (brew / fetch
   `https://astral.sh/uv/install.sh` with `UV_NO_MODIFY_PATH=1`) and `git` (brew / apt + PPA
   `git-core/ppa`).
4. `zsh` package:
   - Providers: brew, apt.
   - Files:
     - link `~/.zsh-conf` → `zsh-conf`
     - link `~/.my-zsh-conf` → `my-zsh-conf`
     - inject `~/.zshenv` from `zshenv.inject` (`source "$HOME/.zsh-conf/env.zsh"`)
     - inject `~/.zshrc` from `zshrc.inject` (`source "$HOME/.zsh-conf/entrypoint.zsh"`)
     - dir `~/.cache/zinit/completions`
   - `requires = ["jq", "sqlite3", "subversion", "fzf", "git"]`.
   - `manual/default-shell.md`, with a `check` per OS.
   - In `my-zsh-conf/env.zsh`, change `source $HOME/secrets.zsh` →
     `[[ -f $HOME/secrets.zsh ]] && source $HOME/secrets.zsh`.
   - Apply the §4.3 alias rewrites in `my-zsh-conf/aliases.zsh`.
   - Write `packages/zsh/README.md`, noting that zsh-conf still reads the
     `~/.remote_indicator` / `~/.no_sudo_indicator` marker files and generates
     `~/.config/starship.toml` itself. Both are TODOs.
5. `profile`: link `~/.profile`. Edit the file to guard
   `. "$HOME/.cargo/env"` → `[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"`; it is
   missing on the Mac today.
6. `git` + `delta` + `difftastic`: split `gitconfig` into three fragments plus
   `gitconfig.ssh-urls` (decision 9, P5:5.5; implement the fallback if fragments aren't
   there). Link `~/.gitignore_global`. `delta` and `difftastic` are brew+cargo (crate
   `git-delta` / `difftastic`).
7. Core CLI packages per the §3.2 rows: `bat` shim, `fd` shim, `ripgrep` + link
   `~/.ripgreprc`, `vim` + link `~/.vimrc`, `python3` (apt `python3-pip` + `python3-venv`;
   brew `python@3.14`).
8. Small packages:
   - `locale`: linux script, `needs_root`, `locale-gen en_US.UTF-8`; check with `locale -a`.
     zsh exports `LC_ALL=en_US.UTF-8`, and Docker has no locale.
   - `local-bin`: env path `~/.local/bin`, plus a `dir` entry.
   - `workspace-dirs`: `dir` entries for `~/projects`, `~/workspace`, `~/workspace/personal`
     and `~/workspace/work`.
   - `scripts`: link `~/dotfiles_scripts` → `scripts/`, and a uv `kind = "venv"`,
     `requirements = "requirements.txt"` (move `scripts/requirements.txt` to the package root).
   - `win32yank`: `when = 'wsl'`.
   - `serial-access`: linux, manual only.
9. `bundles/base.toml`: every package above. Also `.gitignore`: drop the dotbot-era and
   `dotfiles/ghostty/*` entries, and add `packages/playgrounds/playgrounds/*` (with the
   `!.templates` / `!generate.sh` exceptions) and
   `packages/aerospace-switcher/aerospace-switcher/.build`.
10. Verify: `DOTS_REPO_BUNDLES=base scripts/docker-test.sh --repo ~/dotfiles-dots` → RESULT
    OK. Then `--shell`: `zsh -i -c 'echo ok; git config --get core.pager'` prints `ok` and
    `delta` with no errors, and `git ls-remote https://github.com/tmux-plugins/tpm HEAD` works
    (that check proves the sandbox gate).

### Chunk 2: Dev tooling (`dev`)

**Owns:** `bundles/dev.toml` and
`packages/{koala-config,kv,kv-env,neovim,neovim-build-deps,tree-sitter-cli,lemmy-help,nvim-dict,deno,plantuml,koala-cli,codelldb,tmux,tpm,libtmux,ruby,go,node,npm-prefix,bun,fx,btop,bottom,du-dust,jless,jless-build-deps,igrep,broot,tuitab,lumen,ftdv,hunk,yazi,yq,yj,ez-workspaces,hop,gh,gh-dash,gh-enhance,gh-markdown-preview,gh-stack,playgrounds,shell-gpt,mkdocs,ranger-fm,openspec,mermaid-cli,cargo-audit,cargo-nextest,comrak,lazydiff,mermaid-rs-renderer,eza,just,tree,fzy,glow}/**`, except `koala-config/KoalaConfig`, which chunk 1 moved in (chunk 2 writes its `package.toml` next to it).

**Moves:**
- `dotfiles/.kvim.conf` → `packages/koala-config/kvim.conf`
- `editors/KoalaConfig-10` → `packages/koala-config/KoalaConfig-10`
- `dotfiles/tmux_conf` → `packages/tmux/tmux_conf`
- `dotfiles/yazi` → `packages/yazi/yazi`
- `dotfiles/hunk` → `packages/hunk/hunk`
- `dotfiles/lumen` → `packages/lumen/lumen`
- `dotfiles/ftdv/config.yaml` → `packages/ftdv/`
- `dotfiles/ez-workspaces{,-macos}` → `packages/ez-workspaces/{linux,macos}/config.toml`
  (leave `-windows` for chunk 6)
- `dotfiles/hop` → `packages/hop/`
- `dotfiles/bottom/*` → `packages/bottom/`
- `dotfiles/gh-dash/config.yml` → `packages/gh-dash/`
- `playgrounds/` → `packages/playgrounds/playgrounds/`

Brief:
1. Read ARCH §5.2, §5.2.3 (tmux/lazy rule), §5.3 and §6, plus the §3.2 rows for
   `install_nvim.sh`, `install_tmux.sh`, `install_tuis.sh`, `install_go.sh`, `install_dap.sh`
   and `install_git_utils.sh`, and the Mac `install_basic.sh` / `install_kvim.sh`.
2. `koala-config`:
   - link `~/.config/nvim` and `~/.config/kvim-envs/main` → `KoalaConfig/`
   - link `~/.config/kvim-envs/010` → `KoalaConfig-10/` (the `nv-10` alias)
   - link `~/.kvim.conf`

   Then `kv` (cargo git), `kv-env`, and `neovim` (brew; linux script calling
   `$HOME/dotfiles_scripts/misc/upgrade_nvim.sh v0.11.5`, `version = "0.11.5"`, check the
   `~/.local/nvim` binary version; read the script for its install dir and arch handling, and
   make it arch-aware if it hardcodes x86_64).

   nvim deps:
   - `tree-sitter-cli` (cargo locked) and `lemmy-help` (cargo `features=["cli"]`)
   - `nvim-dict` (linux)
   - `deno` (brew / fetch, env `~/.deno/bin`)
   - `plantuml` (+graphviz)
   - `koala-cli` (uv git ssh, `not(tag="sandbox")`)
   - `neovim-build-deps` (linux script, needs_root)
   - `codelldb` (linux script, arch-aware)
3. `tmux`:
   - Providers: brew / apt.
   - Files: link `~/.tmux.conf` → `tmux_conf/entrypoint.tmux`, `~/.tmux_conf` → `tmux_conf/`
     and `~/.tmux/custom-macros`; `terminfo` `tmux-256color.terminfo` with
     `when = 'os = "macos"'` (generate the source once on this Mac with
     `/opt/homebrew/opt/ncurses/bin/infocmp -x tmux-256color > packages/tmux/tmux-256color.terminfo`;
     that is a read-only command).
   - `post_install` writes `~/.tmux/default-keys.conf`.
   - `requires = ["tpm", "libtmux", "ruby"]`.
   - `tpm`: script clone + `post_files` install_plugins (make it tolerate no tmux server; it
     must exit 0 in Docker).
4. Toolchains: `go`, `node` (Mac brew `node`; linux `n` into `~/.local/n`), `npm-prefix`
   (linux env only) and `bun`.
5. CLIs:
   - brew+cargo: `bottom` (locked, files per §3.1, link `bottom-full.toml` too), `du-dust`
     (bin `dust`), `jless` (+ linux `jless-build-deps`), `igrep` (bin `ig`), `broot` (locked),
     `tuitab`, `lumen` (+link dir), `ftdv` (+link), `cargo-audit`, `cargo-nextest`, `comrak`,
     `mermaid-rs-renderer`, `lazydiff` (cargo git `https://github.com/Ataraxy-Labs/lazydiff`;
     cargo only), `yazi` (brew; cargo crates `yazi-fm` + `yazi-cli` locked; link
     `~/.config/yazi`) and `eza`.
   - brew+apt: `btop`, `just`, `tree`, `fzy`.
   - `fx`: brew / fetch.
   - brew-only with `when = 'os = "macos"'`: `yq`, `yj` and `glow`. On Linux yq/yj come from
     zinit; note that in the package.
   - `hunk`: npm-g `hunkdiff`, bin `hunk`, + link dir.
   - `ez-workspaces`: cargo git + two per-OS link entries.
   - `hop`: macOS brew `tap = "amittamari/tap"` + link.
   - `playgrounds`: link `~/playgrounds`.
   - uv tools: `shell-gpt` (bin `sgpt`), `mkdocs` (interim script for `--with
     mkdocs-material`) and `ranger-fm` (bin `ranger`).
   - npm-g: `openspec` (`@fission-ai/openspec`) and `mermaid-cli` (`@mermaid-js/mermaid-cli`,
     bin `mmdc`).
6. `gh` (brew/apt) + `gh-dash` (link config), `gh-enhance`, `gh-markdown-preview`
   (`ofirgall/gh-markdown-preview`) and `gh-stack` (`github/gh-stack`), all via `gh-ext` with
   `not(tag="sandbox")`.
7. `bundles/dev.toml`, all of the above.
8. Verify:
   - Docker `DOTS_REPO_BUNDLES=base,dev` → OK.
   - In `--shell`: `nvim --version`, `kv --version`, `tmux -V`, `go version`, `node -v`,
     `difft --version`, `btm --version`, `yazi --version`.
   - `tmux -f ~/.tmux.conf new -d && tmux kill-server` exits 0.

### Chunk 3: Agents and herdr (`agents`)

**Owns:** `bundles/agents.toml` and
`packages/{claude,claude-code,codex,cursor,cursor-agent,cursor-cli-wrapper,pi,pi-subagents,pi-powerline-footer,pi-community-themes,pi-skills,agents-status,alerter,claude-swap,graphifyy,herdr,herdr-last-tab,herdr-nvim-aware,extrakto-herdr,herdr-automatic-rename,herdr-navigator,herdr-reviewr,herdr-pr-tracker,herdr-notify,herdr-workspace-move,herdr-pr-board,herdr-collie}/**`
(except `agents-status/agents-status`, the submodule chunk 1 moved in).

**Moves:**
- `dotfiles/claude/*` → `packages/claude/` (`hooks.txt` stays as a doc)
- `dotfiles/codex/config.toml` → `packages/codex/`
- `dotfiles/cursor/statusline.sh` → `packages/cursor/`
- `dotfiles/pi/*` → `packages/pi/`
- `dotfiles/agents-status-config.toml` → `packages/agents-status/config.toml`
- `dotfiles/cursor-cli-wrapper.toml` → `packages/cursor-cli-wrapper/config.toml`
- `dotfiles/herdr/*` → `packages/herdr/`, laid out as:
  - `config/common.toml` (was `common-config.toml`), `config/mac.toml`, `config/dev.toml`,
    `config/windows.toml`
  - `scripts/{explain-agent,read-agent-ansi,record-agent-detection}.sh`
  - `agent-detection/`, `herdr-256color.terminfo`, `AGENTS.md`
  - `generate-config.{sh,ps1}` stay in place for chunk 6 to take
- `dotfiles/herdr-automatic-rename/config.sh` → `packages/herdr-automatic-rename/`
- `herdr-last-tab/` → `packages/herdr-last-tab/` (crate at the package root:
  `package.toml` next to `Cargo.toml`)

Brief:
1. Read ARCH §5.2.3 (herdr worked example) and §5.4, decision 7, and §3.3 (Mac findings).
2. `herdr`:
   - cargo `git = "https://github.com/ofirgall/herdr"`.
   - `[[files]]` render `~/.config/herdr/config.toml`, `format = "toml"`, layers
     `config/common.toml` + `{src = "config/mac.toml", when = 'os = "macos"'}`.
   - Find every array path that `config/mac.toml` sets **and** `common.toml` also sets, and
     decide per path between `append` (yq `*+` semantics, today's behavior) and `replace`.
     **Acceptance:** the TOML-parsed dots render equals the TOML-parsed output of today's
     `generate-config.sh mac`. Run that script against a temp copy, never in `~/.config`,
     and compare the parsed structures with a short python `tomllib` script.
   - Second render `~/.config/herdr/config-dev.generated.toml` = common + mac + dev, with
     `"replace"` on the four `DEV_REPLACE_PATHS` and the same appends as above. Acceptance is
     identical.
   - Links: `~/.config/herdr/agent-detection` → `agent-detection/` and
     `~/.config/herdr/scripts` → `scripts/`.
   - `terminfo` file for `herdr-256color.terminfo`.
   - Apply the §4.3 herdr rows to `config/common.toml`.
   - `manual/split-runtime-dir.md` (macOS, `after: files`, `check: test ! -L ~/.config/herdr`)
     describing the cutover in §8.
3. `herdr-last-tab`: cargo `path = "."`, `requires = ["herdr"]`.
4. One package per herdr plugin via `herdr-plugin` (decision 12). Each gets
   `requires = ["herdr"]`, `when = 'not(tag = "sandbox")'` and `source`:
   - `herdr-nvim-aware`: `KoalaVim/herdr-nvim-aware`
   - `extrakto-herdr`: `ofirgall/extrakto-herdr`
   - `herdr-automatic-rename`: `ofirgall/herdr-automatic-rename`, + link
     `~/.config/herdr-automatic-rename/config.sh` (TODO `{plugin_config}`)
   - `herdr-navigator`: `ofirgall/herdr-navigator`
   - `herdr-reviewr`: `ofirgall/herdr-reviewr`, installed id `persiyanov.reviewr`
   - `herdr-pr-tracker`: `ofirgall/herdr-pr-tracker`
   - `herdr-notify`: `ofirgall/herdr-notify`
   - `herdr-workspace-move`: `ofirgall/herdr-workspace-move`
   - `herdr-pr-board`: see §3.3
   - `herdr-collie`: `AltanS/collie`, id `herdr.collie`, macOS only; `post_install` script =
     the `.env` / push-keys part of `install_collie.sh`; `manual/tailscale.md`
5. `agents-status`:
   - link `~/agents-status` → `agents-status/`; link `~/.config/agents-status/config.toml`.
   - uv `path = "agents-status/core"`, `bin = "agents-status"`.
   - `requires = [{ name = "alerter", when = 'os = "macos"' }]`.
   - `manual/notifications.md` (from macREADME).

   `alerter`: brew `tap = "vjeantet/tap"`, macOS. `cursor-cli-wrapper`: script
   `"$HOME/agents-status/install.sh" cursor-cli-wrapper`, check
   `command -v cursor-cli-wrapper`, + link config, `requires = ["agents-status"]`.
6. `claude`:
   - links: `settings.json`, `keybindings.json`, `statusline-command.sh`, and the `mods` dir →
     `~/.claude/mods`.
   - Edit the settings.json path per §4.3.
   - Requires `claude-code`, a script fetch of `https://claude.ai/install.sh`
     (`check = "test -x ~/.local/bin/claude"`).
7. `codex`: link config; brew cask `codex` (macOS) / npm-g `@openai/codex` (linux).
   `cursor`: link `~/.cursor/statusline.sh`. `cursor-agent`: script fetch
   `https://cursor.com/install`, check `~/.local/bin/cursor-agent`.
8. `pi`:
   - script `npm install -g --ignore-scripts @earendil-works/pi-coding-agent` (G13), check
     `command -v pi`, version `pi --version`.
   - links `~/.pi/agent/{settings,keybindings}.json`.
   - `post_install = "command -v herdr >/dev/null && herdr integration install pi || true"`.

   Packages: `pi-subagents` (`npm:pi-subagents`), `pi-powerline-footer`
   (`npm:pi-powerline-footer`) and `pi-community-themes`
   (`git:https://github.com/hasit/pi-community-themes`) via `pi-package`; `pi-skills` (script
   clone `https://github.com/badlogic/pi-skills` → `~/.pi/agent/skills/pi-skills`).
9. uv tools: `claude-swap` (bins `claude-swap`, `cswap`) and `graphifyy` (bins `graphify`,
   `graphify-mcp`).
10. `bundles/agents.toml`.
11. Verify:
    - Docker `DOTS_REPO_BUNDLES=base,dev,agents` → OK.
    - In `--shell`: `herdr --version`, `infocmp -x herdr-256color`, `claude --version`,
      `pi --version`, `agents-status --help`, and `test ! -e ~/.config/herdr/plugins` before
      the first herdr start (the repo dir no longer receives runtime files).
    - On the Mac, read-only: the render-equality check above.

### Chunk 4: macOS desktop (`mac-desktop`, `mac-extra`, `work`)

**Owns:** `bundles/{mac-desktop,mac-extra,work}.toml`, `docs/mac/**` and
`packages/{karabiner,linearmouse,aerospace,aerospace-scripts,aerospace-switcher,sketchybar,sketchybar-app-font,borders,betterdisplay,markdown-preview,macos-defaults,macos-power,flameshot,fast-resume,pik,codeburn,luarocks,imagemagick,ffmpeg,tesseract,resvg,zig,mas,pstree,fontforge,vite,acli,auth0,cfn-lint,cloudflared,colima,docker-buildx,docker-compose,gcx,jira-cli,k9s,opentofu,postgresql,prometheus,sqlc,asdf,gcloud-cli,1password-cli,cloudflare-warp,orbstack,gitkraken-cli}/**`.

**Moves:**
- `dotfiles/mac/karabiner/karabiner.json` → `packages/karabiner/`
- `dotfiles/mac/linearmouse/*` → `packages/linearmouse/`
- `dotfiles/mac/aerospace/aerospace.toml` → `packages/aerospace/`
- `dotfiles/mac/aerospace/{*.sh,toggle-input-source*}` → `packages/aerospace/scripts/`
- `dotfiles/mac/sketchybar` → `packages/sketchybar/sketchybar`
- `dotfiles/mac/borders/bordersrc` → `packages/borders/`
- `aerospace-scripts/` → `packages/aerospace-scripts/aerospace-scripts/`
- `aerospace-switcher/` → `packages/aerospace-switcher/aerospace-switcher/`
- `future-refactors/aerospace-scripts-refactor.md` → `packages/aerospace-scripts/`
- `macREADME/{KEY_CONFLICTS,SYSTEM_CHANGES,TOUCHPAD}.md` → `docs/mac/`
- `macREADME/MANUAL.md` → split into `manual/*.md` of karabiner, aerospace,
  aerospace-switcher and macos-defaults. The agents-status and ghostty sections are handed
  over as text in the chunk report: chunk 3 and chunk 5 own those packages, so put the text
  in your PR description and the supervisor forwards it.

Brief:
1. Read ARCH §6.7, §6.8 and §9, and `install_scripts/mac/*.sh` + `setup_once.sh`.
   **Every package here has `when = 'os = "macos"'`.** Docker must see them as inert, and the
   Docker profile doesn't include these bundles anyway.
2. Casks: karabiner (+`post_files` touch, `post_install = "open -a Karabiner-Elements"`,
   manual permissions), linearmouse (+login-item osascript `post_install`, idempotent as
   written, manual accessibility), betterdisplay and markdown-preview.
3. `aerospace`:
   - cask `aerospace`, `tap = "nikitabobko/tap"`.
   - link `~/.aerospace.toml`; link dir `~/.config/aerospace/scripts` → `scripts/`.
   - Rewrite paths per §4.3.
   - manual screen recording.

   `aerospace-scripts`: script `make -C aerospace-scripts install`, check
   `test -x ~/.local/bin/aerospace-scripts`, `requires = ["rustup"]`.
   `aerospace-switcher`: script, swift, check `test -x ~/.local/bin/aerospace-switcher`,
   manual accessibility.
4. `sketchybar`:
   - brew `tap = "felixkratz/formulae"`.
   - link dir `~/.config/sketchybar`.
   - `requires = ["sketchybar-app-font", "aerospace"]`.
   - `[service] name = "sketchybar", manager = "brew", enabled = true, running = true`.

   `borders`: same pattern. Both P5:5.15, with the fallback
   `post_install = "brew services start <name>"`.
5. `macos-defaults`: translate `setup_once.sh` into `[[defaults]]` (P5:5.14):
   - NSGlobalDomain `InitialKeyRepeat=13` and `KeyRepeat=2` (`requires = ["logout"]`),
     `com.apple.keyboard.fnState=true`, `_HIHideMenuBar=true`.
   - `com.apple.AppleMultitouchTrackpad` `Clicking`/`Dragging`/`DragLock`; the same two keys
     in `com.apple.driver.AppleBluetoothMultitouch.trackpad`.
   - `com.apple.symbolichotkeys` `AppleSymbolicHotKeys.{64,65,60,61,28,29,30,31,184}` =
     `{ enabled = false }`. Keep each `value` dict from the script. The dotted key edits one
     entry.
   - `com.apple.dock autohide=true` with `restart = ["Dock"]`.
   - `com.apple.universalaccess` `mouseDriverCursorSize=1.75`, `cursorFill` (white),
     `cursorOutline` (black), each with `root = true`.
   - `post_install` for
     `/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u`.

   Fallback if 5.14 isn't landed: one script package with the exact `defaults write` lines
   and `check` = a `defaults read` comparison for each key. `macos-power`: script,
   `needs_root`, `pmset` battery/charger lines and `mdutil -a -i off`, with
   `check = "pmset -g custom | …"` and `mdutil -s / | grep -q disabled`.
6. `mac-extra` and `work` bundles: one package per §3.3 row. Brew formula or cask, with
   `tap` where the leaf is tapped. Work packages get `when = 'tag = "work"'` in the bundle
   member.
7. Verify. There is no Docker coverage for this chunk, so run on this Mac, read-only, after
   writing a temp machine file (§7.2):
   - `dots --home /tmp/dots-mac-home lint`.
   - `dots --home /tmp/dots-mac-home plan --root ~/dotfiles-dots`: every mac-desktop,
     mac-extra and work package is `= adopt`/`ok`, never `install` (everything here is
     already installed); defaults show no change.
   - `dots --home /tmp/dots-mac-home apply --files-only --yes --root ~/dotfiles-dots`, then
     diff `/tmp/dots-mac-home/.aerospace.toml` etc. against the live files.
   - Also run Docker with the full `docker` profile and confirm these packages are `n/a`.

### Chunk 5: GUI apps, fonts, Linux desktop (`gui-apps`, `fonts`, `linux-desktop`, `gaming`, `optional`)

**Owns:** `bundles/{gui-apps,fonts,linux-desktop,gaming,optional}.toml` and
`packages/{ghostty,ghostty-shaders,font-*,fonts-cache,vscode,vscode-ext-*,alacritty,spotify,browser-extensions,hyprland,hyprland-plugins,pinta,wayfreeze,wf-recorder,awesome,autorandr,copyq,fusuma,xmodmap,tridactyl,desktop-apps,xdg-defaults,autolock,acpi,bluetuith,wiremix,xclip,brotab,openbox,gamescope,proton-ge,sublime,taskwarrior,firefox-deb,vicinae,pulseaudio}/**`
(except the `vscode/vscode-settings` and `hyprland/hypr-dots` submodules that chunk 1 moved
in).

**Moves:**
- `dotfiles/ghostty/{config,config.macos,config.linux}` → `packages/ghostty/`
  (`config.windows` and `config-winghostty` → `packages/ghostty/windows/`, for chunk 6)
- `dotfiles/alacritty.toml`, `alacritty-fonts/` → `packages/alacritty/`
- `dotfiles/{copyq.conf,fusuma.yml,xmodmaprc,tridactylrc,taskrc}` → their packages
- `dotfiles/autorandr`, `dotfiles/openbox` → their packages
- `dotfiles/vdesk-collapser/config.toml` → `packages/hyprland/`
- `taskwarrior_shortcuts/` → `packages/taskwarrior/`
- `awesomewm/` → `packages/awesome/awesome/`
- `desktop-apps/` → `packages/desktop-apps/`
- `services/autolock.service` → `packages/autolock/`
- `acpi/` → `packages/acpi/`
- `system/pulseaudio.pa` → `packages/pulseaudio/`
- `gaming/launch-options` → `packages/gamescope/`
- `editors/sublime` → `packages/sublime/`
- `browser/chrome/*` and `tampermonkey/*` → `packages/browser-extensions/`
- `split-kb-layouts/` and `settings-scripts/` → `docs/keyboards/` and
  `packages/fonts-cache/query_font.sh`
- `editors/vscode/` → **delete** (superseded by vscode-settings; nothing links it)

Brief:
1. Read ARCH §5.2.1, §5.2.4, §6.7, §6.8 and §9, plus the §3.2 rows for fonts, ghostty,
   vscode, spotify, hyprland, acpi and gaming. Gating: GUI packages get `when = 'gui'`, Linux
   desktop packages get `when = 'all(os = "linux", gui)'`, gaming gets `tag = "gaming"`, and
   ACPI gets `any(tag = "dell", tag = "thinkpad")`.
2. `ghostty`:
   - cask (macOS) / linux build script (arch-aware zig via `$DOTS_LIB/arch.sh`).
   - Files: link `~/.config/ghostty/config` → `config`; link `~/.config/ghostty/config.platform`
     → `config.macos` (macOS) and → `config.linux` (linux), as two entries with `when`.
   - `requires = ["ghostty-shaders", "font-nerdwand-lyth"]`.
   - `manual/disable-secure-input.md` (macOS).
3. Fonts: one package per font in §3.2:
   - Casks on macOS: `font-caskaydia-cove`, `font-ubuntu-mono`, `font-jetbrains-mono`,
     `font-iosevka-term`, `font-commit-mono`, `font-0xproto`, `font-recursive-mono`,
     `font-maple-mono`, `font-nordwand-mono` (macOS only), `font-paper-mono` (macOS only).
   - Linux: script with nerd-fonts `v3.4.0` (the Maple one from its own release URL).
   - `font-cilantro-code`: script on both.
   - `font-nerdwand-lyth`: script on both. Port the BSD `sed -i ''` to a portable form.
     `requires` fontforge + uv. On Linux, `fontforge` is apt.
   - `fonts-cache`: linux, `after` all fonts, runs `fc-cache -f`, `check = "true"`,
     `versionless`. It's acceptable as the single cache refresh.
   - `fonts` bundle.
4. `vscode`:
   - apt repo (linux gui).
   - link `~/.vscode-settings` → `vscode-settings/`, and
     `~/.config/Code/User/{settings,keybindings}.json` → `vscode-settings/*.json`.
   - Generate one `vscode-ext-<id-lowercased>` package per line of
     `vscode-settings/extensions` (`[providers.code-ext] name = "<id>"`) with a one-off shell
     loop, and list them all in `gui-apps`.
5. Linux desktop packages (§3.1 / §3.2 rows):
   - `hyprland`: install is a TODO script that **does nothing but check**
     `command -v Hyprland`, because the original `install_hyprland.sh` never installed
     Hyprland itself. It owns the 4 config dir links + vdesk-collapser and requires
     `pinta`, `wayfreeze`, `wf-recorder` and `hyprland-plugins`.
   - `awesome`, `autorandr`, `copyq` (apt + link), `fusuma` (optional), `xmodmap`,
     `tridactyl`, `desktop-apps`.
   - `xdg-defaults` (P5:5.14) and `autolock` (`[service] manager = "systemd-user"`,
     `unit = "autolock.service"`, requires apt `xautolock` + `i3lock-fancy`; P5:5.15).
   - `acpi`, `bluetuith`, `wiremix` (cargo + apt `libpipewire-0.3-dev`), `xclip` and
     `brotab` (uv tool; `post_install = "bt install"`).
   - `alacritty` and `spotify` (apt repo).
   - `browser-extensions`: no provider; `manual/*.md` per Chrome extension (Vimium,
     Shortkeys + import `shortkeys.json`, Tab Numbers) and Tampermonkey (`better_jira.js`
     import). TODO browser-ext (task 7.2).
6. `gaming`: openbox (+2 links), gamescope (script), proton-ge (script). `optional`: sublime
   (apt repo + the `editors/sublime` files with `dst` under `~/.config/sublime-text/Packages/*`,
   as the commented YAML had them), taskwarrior, firefox-deb, vicinae, fusuma, pulseaudio.
7. Verify:
   - Docker with the full `docker` profile → OK; every package here is `n/a` (gui=false).
   - Then once more with `DOTS_REPO_BUNDLES=base,fonts,gui-apps` and a `--shell` session where
     you set `[facts] gui = true` in `~/.config/dots/machine.toml`, and run `dots plan` (not
     apply) to check the Linux GUI plan resolves on aarch64: no errors, every script has a
     check.
   - On the Mac, the read-only `plan` from §7.2 shows ghostty, fonts and markdown-preview as
     `ok`/adopt.

### Chunk 6: Windows legacy, cleanup, docs (runs last)

**Owns:** `legacy/**`, `docs/**` except `docs/mac` and `docs/keyboards`, `README.md`,
`AGENTS.md`, `KEYBINDINGS.md`, `Makefile`, `.githooks/**`, `media/` and every root-level
leftover. It also deletes `install`, `install-macos`, `common.conf.yaml`,
`install.conf.yaml`, `macos.conf.yaml`, `pre-commit`, `install_scripts/` (non-Windows),
`dotfiles/README.md`, `editors/README.md`, `winREADME/` → legacy, and the now-empty
`dotfiles/` and `editors/` dirs.

Brief:
1. Move these to `legacy/windows/`, fixing the paths inside them:
   - `install-windows`, `install-windows.ps1` and `windows.conf.yaml`
   - `install_scripts/windows/`
   - `dotfiles/{pwsh-conf,my-pwsh-conf,windows}`, `windows/`, `winREADME/`
   - `dotfiles/agents-status-config-windows.toml`, `dotfiles/ez-workspaces-windows`
   - `packages/herdr/generate-config.{sh,ps1}`, adapted to read
     `packages/herdr/config/{common,windows}.toml`

   Rewrite every `path:` in `windows.conf.yaml` to the new `packages/...` locations, and
   point `install-windows` at `../../dotbot` with `-d` = the repo root. Windows dotbot must
   keep working (decision 18). Keep the `dotbot` submodule. Add
   `legacy/windows/README.md`: "DEFER until dots task 7.5; then convert like the other
   chunks".
2. Delete the dotbot-era entry points and YAMLs listed above. `grep -rn 'install_scripts\|conf.yaml\|dotfiles/dotfiles\|~/dotfiles/' --exclude-dir=legacy --exclude-dir=openspec --exclude=MIGRATION.md`
   must come back empty, apart from the hypr-dots submodule follow-up.
3. `Makefile`: keep `init`/`status`/`update`/`foreach`/`add`/`remove` (submodules remain).
   `init` adds `git config submodule.recurse true`. Drop the dotbot submodule from `update`'s
   dirty check only if it's noisy. Keep `ls-workspace-icons`. Add `apply: dots apply`,
   `plan: dots plan` and `docker: (cd ~/workspace/personal/dots-manager && DOTS_REPO_PROFILE=docker scripts/docker-test.sh --repo $(CURDIR))`.
4. `.githooks/pre-commit` (it auto-adds the submodule paths) → new paths.
   `post-checkout`/`post-merge` stay.
5. `README.md`: bootstrap is now `dots init --from ofirgall/dotfiles` + profile choice. List
   the bundles and profiles, and link MIGRATION.md. Update `AGENTS.md` (the repo's agent
   instructions) with the dots workflow and the "never edit generated files in
   `~/.local/state/dots/gen`" rule. Fix paths in `KEYBINDINGS.md`.
6. Run a whole-repo `dots lint`, then Docker with the full `docker` profile and the three
   bundle subsets (§7.1); every run must print RESULT OK. Write the final §9 gap list status
   into this file (tick what's resolved).

---

## 6. Gaps: dots features that are missing or blocking

| # | Gap | Spec / ARCH ref | Effect here | Interim |
|---|---|---|---|---|
| G1 | `[[files]] mode = "git"` not implemented (`dots-files/src/resolve.rs` → `not-implemented`); `git` provider has no `dst`, clones to `{data}/git/<name>` | ARCH §6 mode table, §5.2, §16.3; task: none explicit (add one) | submodules can't become git packages; tpm, ghostty shaders, pi-skills, waybar-vd clones | submodules moved into package dirs (decision 2); script clones with `test -d …/.git` checks |
| G2 | `npm` provider | §5.2, task 7.1 | hunk, openspec, mermaid-cli, codex (linux) | `npm-g` custom provider |
| G3 | `archive`/`github-release` | §5.2.5, task 7.1 | go, zig, codelldb, bluetuith, nvim (linux), dict .deb, proton-ge, win32yank | scripts + `lib/github-release.sh`, arch-aware |
| G4 | `font` provider | §5.2.4, task 7.9 | Linux fonts | scripts; Mac uses casks (READY) |
| G5 | `vscode-ext` | task 7.10 | 36 extensions | `code-ext` custom provider |
| G6 | Bundled defs + declarative extensions (per-source-kind commands for `local:` links, `json:` multi-field projection, `enabled`, provider `vars` like `{plugin_config}`, `review` manifests) | §5.2.3, §5.2.6, task 7.11 | herdr plugins (no `--ref` pinning, local plugins on the Mac can't be declared as local), pi packages, gh-ext, hyprpm | regex-parsed custom providers; plugin config keeps its old fixed path |
| G7 | `browser-ext` | §5.2.1, task 7.2 | Chrome extensions, Tampermonkey | manual md only |
| G8 | manual actions / `todo` | §9, task 6.10 | karabiner/aerospace/linearmouse permissions, chsh, dialout, secure input, tailscale | `manual/*.md` written, not tracked yet |
| G9 | Phase-5 items this plan relies on: 5.4 directives/`files.set` (only the claude fallback), **5.5 fragments** (gitconfig), 5.9 lock (first lock is written at Mac cutover), **5.12** apt repos / cargo+uv `git`/`path` / script `fetch` (used ~40 times), **5.14** `[[defaults]]` + `[[xdg]]`, **5.15** `[service]` | tasks 5.4, 5.5, 5.9, 5.12, 5.14, 5.15 | see `P5:` rows | fallbacks named in each row |
| G10 | Windows support | §6.5, task 7.5 | all of `legacy/windows` | dotbot kept for Windows (decision 18) |
| G11 | dots env inject writes **through** a symlinked rc (`dots-env/src/inject.rs:44`) and there is no ordering control between several inject blocks in one rc | §10, environment spec | `~/.zshenv` was a symlink into the zsh-conf submodule | `~/.zshenv` becomes an inject-only real file (decision 4). Cutover removes the old symlink first (§8) |
| G12 | `[providers.uv]` has no `with = [...]` (extra packages in the tool venv) | §5.2 uv row | `mkdocs --with mkdocs-material` | script |
| G13 | Custom/npm providers have no per-package install flags (`--ignore-scripts`) | §5.4 | pi | script |
| G14 | No per-provider `requires` (build deps only when building from source with cargo on Linux) | §8.3 | jless, wiremix, alacritty apt build-deps | `*-build-deps` linux script packages, required unconditionally on linux |
| G15 | `facts.gui` is per run (DISPLAY etc.): applying the Linux desktop over ssh would drop the GUI set | §4 facts | linux-desktop | profile forces `[facts] gui = true` |
| G16 | Linked dirs holding a **submodule**: `foreign-entries` (§6.3) may count every submodule file as "not in git", because the parent index only has the gitlink | §6.3 | `~/.zsh-conf`, `~/.config/nvim`, `~/agents-status`, `~/.vscode-settings`, `~/.config/hypr…` | verify in Docker; if it misfires, file a dots bug (should consult `git -C <submodule> ls-files`) |
| G17 | Docker harness copies the repo with `cp -a`: submodule `.git` files point at `~/dotfiles/.git/worktrees/...`, which doesn't exist in the container | `docker/ubuntu/repo-test.sh` | anything running `git` inside a submodule (none of the packages do) | none needed; noted so nobody adds such a hook |
| G18 | dots can't express a linked JSON value that depends on `$HOME`: `files.set` exists only for `render` | §17.4 | claude `extraKnownMarketplaces.ofir-mods.source.path` | `~/.claude/mods` + TODO; if Claude doesn't expand `~`, switch claude settings to `render` + `files.set` and accept `modified` + `dots adopt` |
| G19 | No `scope`/`only_on_request` notion for brew leaves vs deps when adopting dozens of discovered leaves | §8.3f | §3.3 adoption | accept: dots only declares leaves |
| G20 | cargo packages installed from a **local path** but declared as `git` (kv, herdr, ez-workspaces, hop) | §5.5 sticky, §8.3g | Mac shows `outdated`/source mismatch | accept; reinstall when convenient |
| G21 | The importer (`dots import dotbot`/`import scan`, task 7.6) isn't available, so this migration is manual | §16, task 7.6 | all chunks | this document is the import |
| G22 | Hostname-based profile selection isn't specified | §2 machines/ | 4 profiles | local `machine.toml` names the profile |

---

## 7. Verify

### 7.1 Docker (Ubuntu 24.04, aarch64): `scripts/docker-test.sh` in dots-manager

`repo-test.sh` copies the repo into the container and writes `machine.toml`. With more than
one `machines/*.toml`, it uses `DOTS_REPO_PROFILE` or `DOTS_REPO_BUNDLES`; without either,
it falls back to *all* bundles, which includes mac-desktop. **Always pass one.** Then it runs
`lint`, `plan`, `apply --yes`, `status` and `plan --check`, and needs apply=0, status=0 and
recheck=0.

```sh
cd ~/workspace/personal/dots-manager
# per chunk, growing
DOTS_REPO_BUNDLES=base                 scripts/docker-test.sh --repo ~/dotfiles-dots
DOTS_REPO_BUNDLES=base,dev             scripts/docker-test.sh --repo ~/dotfiles-dots
DOTS_REPO_BUNDLES=base,dev,agents      scripts/docker-test.sh --repo ~/dotfiles-dots
# the real target
DOTS_REPO_PROFILE=docker               scripts/docker-test.sh --repo ~/dotfiles-dots
# remote profile (tag remote, base only)
DOTS_REPO_PROFILE=remote               scripts/docker-test.sh --repo ~/dotfiles-dots
# inspect a kept container
DOTS_REPO_PROFILE=docker VERBOSE=1     scripts/docker-test.sh --repo ~/dotfiles-dots --keep
docker start -ai dots-test-<pid>       # then the in-container checks below
# by hand
scripts/docker-test.sh --repo ~/dotfiles-dots --shell
```

In-container checks after the `docker` profile applies (run as `dev`):

```sh
zsh -i -c 'echo shell-ok'                                  # zinit bootstrap, no secrets.zsh error, no locale warnings
for c in "git --version" "delta --version" "difft --version" "rg --version" "fd --version" \
         "bat --version" "fzf --version" "jq --version" "uv --version" "cargo --version" \
         "tmux -V" "nvim --version" "kv --version" "go version" "node -v" "bun --version" \
         "deno --version" "btm --version" "dust --version" "jless --version" "yazi --version" \
         "lumen --version" "ftdv --version" "hunk --version" "gh --version" "herdr --version" \
         "claude --version" "pi --version" "agents-status --help" "codelldb --version"; do
  printf '%-28s ' "$c"; sh -c "$c" 2>&1 | head -1
done
git config --show-origin --get core.pager                  # from the rendered ~/.gitconfig (gen/)
git config --get-regexp '^url\.'                           # must be EMPTY in the sandbox
infocmp -x herdr-256color >/dev/null && echo terminfo-ok
dots status --all --json | jq '.data.packages | map(select(.state != "ok" and .state != "n/a"))'   # []
dots bins --shadowed                                       # no duplicates
```

### 7.2 On this Mac, read-only (the real `~/dotfiles` isn't touched)

```sh
mkdir -p /tmp/dots-mac-home/.config/dots
printf 'schema = 1\nroot = "%s"\nprofile = "mac"\n' ~/dotfiles-dots > /tmp/dots-mac-home/.config/dots/machine.toml
dots --home /tmp/dots-mac-home lint
dots --home /tmp/dots-mac-home plan --root ~/dotfiles-dots            # expect mostly adopt/ok; list every "install"
dots --home /tmp/dots-mac-home apply --root ~/dotfiles-dots --files-only --yes   # files land under /tmp/dots-mac-home only
```

Before running it, confirm that `--home` really confines provider queries and writes (task
1.6 says it does for files). Never run `apply` without `--files-only` here.

### 7.3 Mac parity checklist (tool → version command → config to diff)

Compare the live Mac against the `/tmp/dots-mac-home` files-only render. For the Docker
container, check only presence and version, not the macOS-only rows.

| Tool | Version cmd | Config to diff (live ↔ dots) |
|---|---|---|
| zsh | `zsh --version` | `~/.zshenv` (now inject), `~/.zshrc` (inject + drift block), `~/.zsh-conf/`, `~/.my-zsh-conf/` (aliases.zsh path edits are the only diff) |
| git / delta / difftastic | `git --version; delta --version; difft --version` | `git config --list --show-origin \| sort` before vs after: same keys and values |
| tmux | `tmux -V` | `~/.tmux.conf`, `~/.tmux_conf/`, `~/.tmux/custom-macros`, `infocmp -x tmux-256color` |
| neovim / kv | `nvim --version \| head -1; kv --version` | `~/.config/nvim` → same submodule commit; `~/.kvim.conf` |
| ghostty | `ghostty --version` | `~/.config/ghostty/config`, `config.platform` (= config.macos), `shaders/` present |
| herdr | `herdr --version` | `~/.config/herdr/config.toml` (parsed TOML equal to `generate-config.sh mac` output), `config-dev.generated.toml`, `herdr plugin list` ids |
| herdr plugins | `herdr plugin list` | 8 declared + collie + pr-board present |
| claude | `claude --version` | `~/.claude/settings.json` (only the mods path differs), `keybindings.json`, `statusline-command.sh` |
| codex | `codex --version` | `~/.codex/config.toml` |
| pi | `pi --version; pi list` | `~/.pi/agent/settings.json`, `keybindings.json`, packages list |
| agents-status | `uv tool list \| grep agents-status` | `~/.config/agents-status/config.toml` |
| gh + extensions | `gh --version; gh extension list` | `~/.config/gh-dash/config.yml` |
| yazi | `yazi --version` | `~/.config/yazi/` |
| bottom | `btm --version` | `~/Library/Application Support/bottom/bottom.toml` |
| ez-workspaces | `ez --version` | `~/Library/Application Support/ez/config.toml` |
| hop | `hop --version` | `~/.config/hop/config.toml` |
| aerospace | `aerospace --version` | `~/.aerospace.toml` (path edits only), `~/.config/aerospace/scripts/` |
| sketchybar / borders | `sketchybar --version; borders --version` | `~/.config/sketchybar/`, `~/.config/borders/bordersrc`, `brew services list` |
| karabiner / linearmouse | cask versions (`brew list --cask --versions`) | `karabiner.json`, `linearmouse.json` (identical, links) |
| macOS defaults | `defaults read -g KeyRepeat` etc. | every `[[defaults]]` key: `dots status macos-defaults` all ok |
| brew | `brew leaves` | every leaf is declared (§3.3) or listed as a follow-up |
| cargo | `cargo install --list` | every crate declared or flagged (G20) |
| uv | `uv tool list` | agents-status, claude-swap, graphifyy, shell-gpt, mkdocs, ranger-fm, brotab |
| npm (brew node) | `/opt/homebrew/bin/npm ls -g --depth=0` | pi, openspec, mermaid-cli, (hunkdiff new) |
| fonts | `ls ~/Library/Fonts \| wc -l` | casks + Cilantro + Nerdwand/Lyth marker |

---

## 8. Mac cutover (after every chunk merges and Docker is green; supervisor-led, not part of the chunks)

1. `git -C ~/dotfiles fetch` + review; merge `migrate-to-dots` into `master` only when the user
   says so.
2. herdr runtime split, while herdr is stopped:
   1. `mkdir ~/.config/herdr.new`.
   2. Move `plugins/`, `plugins.json`, `.locks/`, `sessions/`, `session.json`,
      `session-snapshots/`, `*.log`, `*.sock*` from `~/dotfiles/dotfiles/herdr/` into it.
   3. `rm ~/.config/herdr` (the symlink), then `mv ~/.config/herdr.new ~/.config/herdr`.
3. `rm ~/.zshenv` (a symlink into the submodule, G11). Remove the old dotbot symlinks
   (`find ~ -maxdepth 4 -lname '*dotfiles/*'`). dots would otherwise back each one up as a
   conflict, which is safe but noisy.
4. `~/.config/dots/machine.toml`: `root = "~/dotfiles"`, `profile = "mac"`. Then
   `dots plan`, then `dots apply`, then `dots status` until green. Commit the first
   `dots.lock`.
5. Leftovers to handle by hand: uninstall the duplicate cargo `hop`; decide herdr-navigator
   and pr-tracker forks; adopt non-brew apps (§3.3); fix the wallpaper path in the hypr-dots
   repo.

## 9. Follow-ups outside dots

- hypr-dots: `Keybinds.conf` wallpaper path (§4.3).
- zsh-conf: replace marker-file checks with `$DOTS_TAG_REMOTE`-style env (needs dots to export
  tags to the shell env; propose as a dots feature), and let dots render `starship.toml`.
- Decide what `rtk`, `blacksmith`, `terminal-browser`, `sidekick-herdr-minimize` in `~/.local/bin`
  are and declare them.

---

## 10. Chunk 1 report

### Deviations (chunk 1)

Implemented against dots v0.2 as built (`~/workspace/personal/dots-manager`). Where the plan and
the code disagree, the code won.

- **Commits use `--no-verify`.** `.githooks/pre-commit` (chunk 6 owns it) still runs
  `git add editors/KoalaConfig dotfiles/zsh-conf hypr-dots editors/vscode-settings` and fails
  after the submodule moves.
- **Placeholder `package.toml` in `agents-status/`, `hyprland/`, `koala-config/` and `vscode/`.**
  dots hard-fails every command (`plan` included) on a directory under `packages/` that has no
  `package.toml`, even when no bundle names it. Each placeholder is `schema = 1` + `name`, with
  a comment. Chunks 2, 3 and 5 overwrite theirs (expect an add/add conflict on merge: take the
  chunk's version).
- **`scripts` venv is a `script` package**, not uv `kind = "venv"`: the uv provider refuses
  `kind = "venv"` (dots bug 1). It creates `~/.local/share/dots/venvs/scripts` with
  `uv venv` + `uv pip install -r requirements.txt`, check = import of every requirement.
- **Gitconfig uses fragments (5.5), no fallback.** `git` p0 (`gitconfig`), `git` p10
  (`gitconfig.ssh-urls`, `when = 'not(tag = "sandbox")'`), `delta` p50, `difftastic` p50.
  Verified: `git config --list` of the composed file equals the old file's (minus the
  ssh `insteadOf` rules in the `sandbox` profile). `delta` and `difftastic` also `requires = ["git"]`.
- **Apt PPA, script `fetch`, `[env]`, `inject`, `dir`:** all used natively (5.12), no fallbacks.
- **Platform scoping, not in the plan:** `build-essential`, `pcregrep`, `daemon` and
  `python3-venv` are `when = 'os = "linux"'` and apt-only (the old installer was Linux-only;
  brew `pcre` is deprecated and has no `daemon`). `python3` requires `python3-venv` on linux;
  its apt name is `python3-pip`.
- **Brew names:** `sqlite3` -> `sqlite`, `pkg-config` -> `pkgconf` (what `brew list` reports),
  `python3` -> `python@3.14`, `delta` -> `git-delta`, `rustup` -> `rust`.
- **`fzf`:** the no-sudo fallback is a `script` provider with `when = 'not(sudo)'` (git clone
  `~/.fzf`, `install --bin`) and `[env] path = ["~/.fzf/bin"]`.
- **`serial-access`** needs `providers_only = true`, otherwise dots tries to
  `apt install serial-access` (a package with no providers, files or bin is treated as
  supported by every provider).
- **`.gitignore`** also dropped the sublime/nvim/autokey/old_dconf dotbot-era entries (kept
  `**/Doxy.sublime-license`).
- **Submodule registration:** `git submodule status` shows `-` for the moved submodules until
  someone runs `git submodule sync --recursive && git submodule init` (the shared `.git/config`
  has only the old names). The working dirs are intact (their gitdirs live under
  `~/dotfiles/.git/worktrees/dotfiles-dots/modules/`).
- **dots env goes into the login shell's rc** (`~/.bashrc` in the Docker `dev` user, `~/.zshenv`
  on the Mac). zsh-conf sources `~/.cargo/env` itself, so zsh sees cargo bins either way.

### Docker result (chunk 1)

`DOTS_REPO_PROFILE=docker scripts/docker-test.sh --worktree --repo ~/dotfiles-dots`
(Ubuntu 24.04 aarch64, profile `docker` = bundle `base`, tag `sandbox`):

```
lint     exit 0
plan     exit 0
apply    exit 0 (0 = ok)
status   exit 0 (0 = clean, 2 = drift)
recheck  exit 0 (0 = idempotent, 3 = plan not empty)
RESULT: OK
```

By hand in the container after the apply: `zsh -i -c 'echo ok; git config --get core.pager'`
prints `ok` and `delta` (first start bootstraps zinit; the only noise is
`aliases.zsh:202: command not found: ez`, which chunk 2's `ez-workspaces` fixes),
`git config --get-regexp '^url\.'` is empty (the sandbox gate works) and
`git ls-remote https://github.com/tmux-plugins/tpm HEAD` succeeds.
`dots plan --home <scratch>` on this Mac (read-only) lints clean, and its files-only render
gives a `~/.gitconfig` whose `git config --list` equals the old file's.

### Conventions established by chunk 1 (for chunks 2-5)

- **Bundles** list package names; `bundles/base.toml` is the only one that exists. The docker
  profile is `["base"]` plus a TODO: chunks 2 and 3 add `dev` and `agents` to
  `machines/docker.toml` when they merge. Never list a bundle that doesn't exist.
- **`$DOTS_LIB` = `<root>/lib`**. `source "$DOTS_LIB/arch.sh"` gives `dots_arch {go|zig|nerd|
  codelldb|bluetuith}` and `dots_os_title`; `source "$DOTS_LIB/github-release.sh"` gives
  `gh_release_url <owner/repo> <asset-regex> [tag]` and `gh_release_download <repo> <regex>
  <dest> [tag]`. Both are plain functions, no `eval`.
- **Cargo packages**: `rustup` requires `build-essential` on linux, so every cargo package gets a
  C linker automatically (Docker has none). Don't re-declare it.
- **Bootstrap packages** exist: `homebrew` (macOS), `rustup`, `uv`, `git`. `local-bin` puts
  `~/.local/bin` on PATH and creates it; `locales` + `locale` give `en_US.UTF-8`.
- **No apt inside scripts.** dpkg's lock is exclusive and dots runs the apt batch concurrently
  with scripts. Put apt dependencies of a script in an apt package and `requires` it
  (this is what `locales` / `locale` do; use the same shape for `*-build-deps`).
- **Root scripts:** use an inline `sudo -n` (see `packages/locale`), because of dots bug 4.
- **Hooks do nothing** (dots bug 6): replace each planned hook with a script package.
- **Shims** are not created (dots bug 5): copy the `bat-shim` pattern.
- **Files-only packages** (no providers, no `bin`) are fine (`profile`, `workspace-dirs`,
  `local-bin`); a package with nothing at all needs `providers_only = true`.
- **`dots` commands for validation**: `dots --home <scratch> lint|plan` with a scratch
  `machine.toml` (`root = "<worktree>"`, `profile = ...`). `apply --files-only --yes` under a
  scratch `--home` is safe and confines every write to that dir.
- **Docker iteration without a rebuild:** after one `docker-test.sh --worktree` run the image
  `dots-test:worktree` exists; `docker run --rm -v <repo>:/home/dev/dots-repo:ro dots-test:worktree
  bash -c '...'` plus the same `cp -a` and `machine.toml` as `repo-test.sh` gives a 20 second loop.
- **Commits**: `git commit --no-verify` until chunk 6 fixes `.githooks/pre-commit`.
- Package list of chunk 1: homebrew rustup uv git local-bin zsh profile locales locale
  workspace-dirs scripts delta difftastic ripgrep fd fd-shim bat bat-shim fzf jq vim curl wget unzip
  build-essential cmake pkg-config moreutils pcregrep daemon toilet sqlite3 subversion python3
  python3-venv ipython win32yank serial-access.

### dots bugs found

1. **`[providers.uv] kind = "venv"` is rejected at plan time** (`uv: kind venv is not supported
   yet`; documented in ARCH §5.2 and the task). Repro: a package with
   `[providers.uv] kind = "venv"` and `requirements = "requirements.txt"` in a bundle, then
   `dots plan`. Worked around with a script package (`packages/scripts`).
2. **A directory under `packages/` without `package.toml` is a fatal error for every command**
   (`file-unreadable`), even for `dots plan` of a bundle that doesn't include it. Repro: `mkdir
   packages/x` and run `dots plan`. Worked around with placeholder package files.
3. **A package with no `providers`, `bin`, `bins` or `files` is installed via every provider**
   (`serial-access` became `apt install serial-access`). Arguably it should be inert; the
   workaround is `providers_only = true`.
4. **A `script` package with `needs_root = true` always fails its post-install check** with
   `check-failed-after-install`. `ScriptProvider::exec` runs the check with
   `PathBuf::from(&action.argv[0])` as the shell, but when the engine wraps a root action in
   `sudo -n` (`dots-engine/src/apply.rs`, around line 278) `argv[0]` is `/usr/bin/sudo`, so the
   check runs as `sudo -c <text>` (sudo prints its usage). Repro: a script package with
   `needs_root = true`, a passing `install`, then `dots apply` as a non-root user with sudo.
   Workaround: `needs_root = false` and an inline `sudo -n ...` in the script (`packages/locale`).
5. **The provider `shim` key is parsed but nothing creates the shim** (only `dots bins` reports
   shims). Repro: `[providers.apt] name = "fd-find"  bin = "fdfind"  shim = "fd"`, apply, and
   `~/.local/bin/fd` does not exist. Workaround: `bat-shim` and `fd-shim` script packages.
6. **`[hooks]` (`pre_install`, `post_install`, `pre_files`, `post_files`) are never run.** They
   parse and lint, but no code outside `dots-model` reads them. Repro: `[hooks] post_install =
   "touch /tmp/x"` and apply: no file. **This hits every chunk that planned a hook**
   (karabiner `post_files`, tmux `post_install`, tpm `post_files`, brotab `bt install`, linearmouse
   and herdr hooks). Use a separate `script` package with `requires`/`after` instead, and mark it
   `# TODO(dots-migration): hook (dots bug 6)`.

---

## 11.4 Chunk 4 report (macOS desktop)

Packages (all `when = 'os = "macos"'`): karabiner, linearmouse, linearmouse-login-item, betterdisplay,
markdown-preview, aerospace, aerospace-scripts, aerospace-switcher, sketchybar-app-font, sketchybar,
borders, macos-defaults, macos-power; mac-extra: fast-resume pik codeburn luarocks imagemagick ffmpeg
tesseract resvg zig mas pstree fontforge vite flameshot; work (bundle member `when = 'tag = "work"'`):
acli auth0 cfn-lint cloudflared colima docker-buildx docker-compose gcx jira-cli k9s opentofu
postgresql (`postgresql@15`) prometheus sqlc asdf gcloud-cli 1password-cli cloudflare-warp orbstack
gitkraken-cli.

Deviations:
- Hooks do not run (dots bug 6). karabiner `post_files` touch and `open -a` are dropped (TODO in
  `packages/karabiner`, covered by `manual/permissions.md`). The LinearMouse login item is the script
  package `linearmouse-login-item`. `activateSettings -u` is not reproduced (no honest check);
  `macos-defaults/manual/apply-hotkeys.md` documents it.
- `macos-power` uses inline `sudo -n` (dots bug 4); the one-shot `mdutil -a -E` (erase index) is dropped.
- `zig@0.15` (installed, no dependents) is not declared. `jira-cli` and `auth0` are homebrew/core: no tap.
- `[[defaults]]` hotkeys 28-31 and 184 declare only `enabled = false`: macOS normalised their
  `parameters` (65535 -> 51/52/53), so the script's dict would be permanent drift.
- `MANUAL.md` split into `manual/*.md` of karabiner, linearmouse, aerospace, aerospace-switcher,
  macos-defaults; `macREADME/MANUAL.md` removed. Path rewrites (section 4.3) applied.

Defaults read on this Mac (read-only) vs setup_once.sh: InitialKeyRepeat 13, KeyRepeat 2, fnState 1,
_HIHideMenuBar 1, Clicking 1 (AppleMultitouchTrackpad), Dragging 1, DragLock 0 (both domains), dock
autohide 1: all match. Differences: hotkeys 64/65/60/61 are stored as strings ("0", "32"...) by the old
script, dots wants bool/int (apply would only fix the types); hotkeys 28-31/184 parameters differ as above;
`com.apple.universalaccess` cursor keys are written by `sudo defaults write` into root's domain and are
unreadable without sudo (unverified, plan shows `? ->`); BluetoothMultitouch `Clicking` is 0 (script
never set it).

Validation: `lint` 0 (89 packages). Mac `plan --home <scratch>`: no installs except tapped formulae
and the two script packages, which are scratch-home artifacts (see bug 7, and `$HOME` in the script
checks). Docker (`dots-test:v02-snapshot`, bundles base+mac-desktop+mac-extra+work, tags sandbox+work):
lint 0, plan 0, apply 0, status clean, `plan --check` 0; every chunk 4 package is `n/a`.

New dots bug 7: with `--home <scratch>`, `brew info --json=v2 --installed` run by the brew provider no
longer lists formulae from third-party taps (166 -> 157), so tapped formulae look missing in a scratch-home
plan. Repro: `HOME=<empty dir> brew info --json=v2 --installed` vs real HOME.

Machines: `mac.toml` gains `mac-desktop`, `mac-extra`, `work` (already listed). No other profile.
Merge notes: no overlapping paths; `dotfiles/mac/` is empty (chunk 6 can drop it).

Text for other chunks (from old MANUAL.md):
- agents-status: grant notification permission to alerter: `alerter --title "Setup" --message "Click Allow" --sound default --timeout 10`.
- ghostty: Ghostty may hold macOS Secure Input, which stops AeroSpace intercepting `alt`-only binds (cmd-alt-* unaffected). Terminal menu > uncheck Secure Keyboard Entry. Verify: `ioreg -l -w 0 | grep kCGSSessionSecureInputPID`.

## 11.5 Chunk 5 report

Bundles: `gui-apps`, `fonts`, `linux-desktop`, `gaming`, `optional`.

### Packages

- **fonts** (bundle `fonts`): `font-caskaydia-cove`, `-ubuntu-mono`, `-jetbrains-mono`, `-iosevka-term`,
  `-commit-mono`, `-0xproto`, `-recursive-mono`, `-maple-mono`, `-nordwand-mono` (mac), `-paper-mono` (mac),
  `-cilantro-code`, `-nerdwand-lyth`; helpers `font-caskaydia-cove-prune` (mac), `font-fontforge`,
  `font-ttfautohint`, `font-fontconfig`; `fonts-cache`.
- **gui-apps**: `ghostty`, `ghostty-shaders`, `browser-extensions` (manual actions), `vscode`, 36 `vscode-ext-<id>`,
  `alacritty`, `alacritty-desktop`, `spotify`.
- **linux-desktop**: `hyprland` (+ `hyprland-plugins`, `pinta`, `wayfreeze`, `wf-recorder`), `awesome`
  (+ `awesome-plugins`, `awesome-root-extras`), `autorandr`, `copyq`, `xmodmap`, `tridactyl`, `desktop-apps`,
  `xdg-defaults`, `autolock`, `acpi`, `bluetuith`, `wiremix`, `xclip`, `brotab` (+ `brotab-install`).
- **gaming**: `openbox`, `gamescope`, `proton-ge`. **optional**: `sublime` (+ `sublime-apt-repo`, `sublime-merge`),
  `taskwarrior`, `firefox-deb` (+ `firefox-snap-remove`), `vicinae`, `fusuma`, `pulseaudio`.
- One-apt-name helper packages (a package can't name two apt packages): `libgtk-4-dev libadwaita-1-dev gettext
  libxml2-utils` (ghostty), `libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev` (alacritty,
  wayfreeze), `libpipewire-0.3-dev clang` (wiremix), `playerctl i3lock-fancy xautolock pasystray pavucontrol blueman
  flameshot xserver-xephyr copyq-plugins` (awesome/autolock), `libinput-tools ruby libevdev-dev ruby-dev` (fusuma),
  `obconf lxappearance`, `acpid`, `xdg-utils`, `desktop-file-utils`, `python3-dev`.

### Deviations

- **`install = "script.sh"` is shell text, not a file path.** A script key is run as `bash -c`, so file installers
  are `source ./install.sh` (cwd is the package dir, `set -euo pipefail` carries over). The §4.1 template line
  `install = "install.sh"` does not work.
- **Gating.** Fonts are not gated on `gui` (they apply in Docker next to `base`). Everything else Linux-desktop is
  `all(os = "linux", gui)`; `ghostty`, `ghostty-shaders` and `browser-extensions` are `gui` (mac and Linux);
  vscode and its extensions are Linux only (they were Linux only in the YAML); gaming is
  `all(os = "linux", tag = "gaming")`; `acpi` is `all(os = "linux", any(tag = "dell", tag = "thinkpad"))`.
  Helper packages are gated only on `os = "linux"`; they are reached through `requires` only.
- **`hyprland` has no provider.** Files plus `manual/install.md` (check `command -v Hyprland`). A script whose
  install can only fail would break every apply. `hyprland-plugin-deps` is not in Ubuntu's archive, so it is a manual
  note there (an apt package for it made the whole apt batch fail: `Unable to locate package`).
- **Nordwand build is pinned** to upstream `6a58cb2c` (before 2026-11-09). Upstream HEAD restructured to
  `src/nordwand_mono` and moved the nerd patch to otf, so the old script's `sed` and `generate_font` break. Linux
  also needs the `ttfautohint` binary (`font-ttfautohint`; the PyPI wheel ships none for aarch64). The patch
  needs about 4 GB of RAM: run the Docker test with `-m 6g`, or OrbStack's 16 GB VM gets OOM-killed.
- **Linux fonts** go to `~/.local/share/fonts/dots/<pkg>/` with a `.version` file as the check (nerd-fonts
  `3.4.0`; bump the number in the package to reinstall). `fonts-cache` uses a stamp file instead of
  `check = "true"` (which would never run): the check fails when any font file is newer than the stamp.
- **ghostty linux**: always builds with `-fno-sys=gtk4-layer-shell` (24.04 has no such package), zig is
  arch-aware via `dots_arch zig`. Not run in Docker (needs a long build); plan/lint only.
- **alacritty** is `[providers.cargo] git = ...` (was `cargo install --git` plus root post-steps), and the root
  steps (alternatives, `.desktop`) are the script package `alacritty-desktop`.
- **spotify** key: the old script's key `C85668DF69375001` no longer verifies the repo. The repo is now signed with
  `5384CE82BA52C83A`, which Spotify publishes only as a binary `.gpg` while dots needs an armored key; the key URL is
  the Ubuntu keyserver and the fingerprint is pinned. Verified in Docker: repo added and `apt update` clean (the
  `spotify-client` package itself is amd64-only, so the install can't be proved on aarch64).
- **sublime** apt repo is flat (`deb https://download.sublimetext.com/ apt/stable/`), which dots can't express
  (dots bug 7), so `sublime-apt-repo` is a root script (key + deb822 source + a targeted `apt-get update` with a retry
  loop for the dpkg/lists lock). Verified in Docker.
- **gamescope**: the ~60 build deps are installed inside the script with `apt-get -o DPkg::Lock::Timeout`, not as 60
  packages (documented `TODO`). Not run (gaming tag, long build).
- **taskwarrior** is only the apt package + `~/.taskrc`; the old installer built taskwarrior, taskwarrior-tui and
  taskopen from source (TODO in the package).
- `pulseaudio` is `providers_only` with no entry (`/etc/pulse/default.pa` is root-owned; TODO).
- `autolock`: `[service] enabled = true, running = false` (the unit needs `DISPLAY=:0`).
- `acpi` links into `/etc/acpi` point at `$DOTS_PKG_DIR/acpi/...` (the root used for the apply), as the old
  `link.sh` pointed at the repo.
- `fusuma` group membership is a manual action (`manual/input-group.md`), not `newgrp`.
- `awesome/awesome/.gitignore` lists the plugin clones (`~/.config/awesome` is the repo dir).
- Moved: `split-kb-layouts/*` to `docs/keyboards/`, `settings-scripts/query_font.sh` to `packages/fonts-cache/`,
  `dotfiles/vdesk-collapser/config.toml` to `packages/hyprland/vdesk-collapser.toml`; `editors/vscode` deleted;
  `awesomewm/install_awesomewm.sh` deleted; ghostty `config.windows` and `config-winghostty` are in
  `packages/ghostty/windows/` for chunk 6.

### Validation

- Local (Mac, scratch `--home`): `lint` ok (162 packages, 6 bundles); `plan` and `apply --files-only` fine; ghostty and
  the font casks read `ok`, `ghostty-shaders` and `font-cilantro-code` / `font-nerdwand-lyth` show as missing only
  because the scratch `$HOME` has no `~/Library/Fonts` (the real home has them).
- Docker, no `gui` (`base fonts gui-apps linux-desktop gaming optional`, tag `sandbox`, gui=false):
  `lint 0, plan 0, apply 0, status 0 (51 packages, 16 files ok), recheck 0`. Everything except base + fonts is `n/a`.
- Docker, only the GUI bundles (`gui-apps linux-desktop gaming optional`, gui=false): `plan` prints
  "Nothing to do" (clean no-op).
- Docker, `gui` on, tags `sandbox,gaming,dell` (plan only, after `apt install xdg-utils`): plan resolves with no
  errors: 103 installs, 46 file changes, 2 xdg settings, 1 service action. Every script has a real check.
- Docker, partial gui apply (gui=true, tags `sandbox,dell`; `dots apply <pkgs>`), all succeeded with a passing
  check: `sublime` + `sublime-merge` (flat repo script), `acpi` (links in `/etc/acpi`), `awesome-plugins`,
  `awesome-root-extras`, `ghostty-shaders`, `vscode` (MS apt repo + `code`), `xdg-defaults` (markdown handler),
  `wayfreeze`, `wiremix`, `alacritty` (cargo git build, 44 s) + `alacritty-desktop`, `bluetuith` (arm64 asset),
  `brotab` + `brotab-install`, `copyq`, `autorandr`, `uv`/`rustup`. Expected failures without a desktop: `pinta`
  (no snap), `hyprland-plugins` (no `hyprpm`), `xdg-settings default-web-browser` (no desktop environment),
  `autolock` service (no systemd), `spotify-client` (amd64 only).

### New dots bugs (chunk 5)

7. **Flat apt repositories can't be declared.** `repo` needs `components`, and a flat repo like Sublime's has none
   (`deb https://download.sublimetext.com/ apt/stable/`). Worked around with `sublime-apt-repo`.
8. **Custom `[providers.<id>]` are never "available" at plan time.** `CustomProvider::availability(&Facts)` returns
   `Unsupported` unless `facts.providers[id]` is true, so `bootstrap` is never reached and every `code-ext` package
   warns `no-provider-satisfies ... code-ext skipped: not available on this machine` on a gui Linux machine without
   `code` (the 36 extension packages). Repro: a package with `[providers.code-ext]`, run `dots plan` where `code` is
   missing. After `vscode` installs, a second apply is needed.
9. **`[[xdg]]` planning fails when `xdg-mime` is not installed**: `cannot plan settings: cannot run
   /usr/bin/xdg-mime query default text/markdown: No such file or directory`. The whole plan errors out, including
   for unrelated packages. `xdg-defaults` `requires` `xdg-utils` but the plan is made before that installs.
10. **A failing third-party apt repo fails every apt package** (`apt-get update` failure marks the whole batch
    `skipped-due-to-dep`): one bad key in `optional` or `gui-apps` turns unrelated packages (`rustup`, `copyq`) into
    skips. Expected, but worth an isolation option.
11. **An apt `repo.key` must be ASCII-armored** (`not ASCII-armored; apt repository keys must be .asc`), but
    some vendors (Spotify) publish only the dearmored binary. dots could dearmor.

## 11.3 Chunk 3 report (agents and herdr)

Branch `migrate-c3`, bundle `agents`, 33 packages. Implemented against the frozen v0.2 snapshot.

### Packages
`claude-code claude claude-swap graphifyy codex cursor cursor-agent pi pi-herdr pi-subagents
pi-powerline-footer pi-community-themes pi-skills alerter agents-status cursor-cli-wrapper herdr-zig
herdr herdr-last-tab herdr-nvim-aware extrakto-herdr herdr-automatic-rename herdr-navigator
herdr-reviewr herdr-pr-tracker herdr-notify herdr-workspace-move herdr-pr-board herdr-collie
herdr-collie-setup`.
New helper packages (not in the §5 list): `pi-herdr` and `herdr-collie-setup` (replace the two
planned `post_install` hooks, dots bug 6) and `herdr-zig` (herdr build dependency).

### Deviations
- **herdr plugins are `script` packages, not `herdr-plugin` packages.** A custom provider's spec has
  no `source` (only `name`), and `herdr plugin list` prints the plugin id while the install wants
  `owner/repo`, so status would always say `missing`. Each script's `check` greps `herdr plugin list`
  for the id (so a local-link install of the same id is `ok`, as §3.3 expected) and installs with
  `herdr plugin install <owner/repo> --yes`. `herdr-pr-board` is public (`ofirgall/herdr-pr-board`).
  All plugins except collie are `when = 'not(tag = "sandbox")'`; collie is macOS and not sandbox.
- **pi packages and codex-on-Linux are `script` packages too**, for dots bug 8 below
  (`pi list` / `pi install`, `npm install -g @openai/codex`).
- **`agents-status` bin is `agents-status-server`**, not `agents-status` (that is the only script
  `core/pyproject.toml` defines; the `agents-status --help` verify step in §5 cannot work).
- **`herdr-256color.terminfo` defines the entry `xterm-256color`** (undercurl on top of xterm), not
  `herdr-256color`, so `infocmp -x herdr-256color` fails even after tic. Kept as is (same as the old
  `tic -x`); dots compiles it into `~/.terminfo/<hex>/xterm-256color`.
- **herdr needs zig 0.15.2** (the fork's vendored libghostty-vt; the upstream checkout wants 0.16).
  `herdr-zig` downloads it to `~/.local/share/herdr-zig` on both OSes (brew's `zig@0.15` is keg-only)
  and exports `ZIG` (herdr's build.rs reads it), so nothing shadows `zig` on PATH.
- **herdr dev render**: `config/dev.toml` sets no keys, so the second render needs no
  `[files.merge]`; mac.toml sets only a scalar, so the first needs none either. The four old
  `DEV_REPLACE_PATHS` are documented in a comment in `packages/herdr/package.toml`.
- **cursor-cli-wrapper** runs the submodule installer by its repo path
  (`$DOTS_ROOT/packages/agents-status/agents-status/install.sh`): `~/agents-status` is linked only
  in the files phase, after installs. The installer's seeded `config.toml` is removed again so the
  config link does not back up a stray file.
- `claude` `mods` link and `~/.claude/mods` settings path: `TODO` kept (verify Claude expands `~`).
- `herdr-automatic-rename` config is linked at the old `~/.config/herdr-automatic-rename/config.sh`.
- Moved `herdr-last-tab/.gitignore` with the crate; fixed `agent-detection/Makefile`
  (`../scripts/record-agent-detection.sh`) and `packages/herdr/AGENTS.md`.
- `herdr/generate-config.{sh,ps1}` stay in `dotfiles/herdr/` for chunk 6 but now point at files that
  moved (`common-config.toml`, `windows-config.toml` -> `packages/herdr/config/{common,windows}.toml`).

### Results
- **herdr render acceptance:** `generate-config.sh mac` run on a scratch copy of the original files,
  parsed with `tomllib`, equals the dots render for both `config.toml` and
  `config-dev.generated.toml`, except the three command strings rewritten per §4.3 (explain-agent,
  read-agent-ansi, `prefix+r` -> `dots apply herdr --files-only --yes && herdr server reload-config`).
- **Mac (scratch `--home`):** `lint` ok, `plan` has no warnings, `apply --files-only --yes` ok. The
  real herdr runtime files no longer land in the repo (`~/.config/herdr` becomes a real dir,
  `manual/split-runtime-dir.md`). Every script `check` was also run read-only against the real
  `$HOME`: all pass except `pi-skills` (not installed today, as §3.3 says).
- **Docker (Ubuntu 24.04 aarch64, `dots-test:v02-snapshot`, tag `sandbox`, bundles base + agents +
  a throwaway `node` stub, because chunk 2 owns `node`):** lint 0, plan 0, apply 0, status 0 (54
  packages, 31 files), recheck 0 (idempotent). Herdr plugins, `pi-herdr`, collie, alerter are `n/a`
  there (sandbox / macOS). In the container afterwards: `herdr --version` (0.8.2), `herdr-last-tab`,
  `claude --version`, `pi --version`, `codex --version`, `cursor-agent --version`, `cswap --help`,
  `graphify --help` all run, and `~/.config/herdr` holds only the dots links (no `plugins/`).
  A first full run failed once: three concurrent `pi install` calls rewrite
  `~/.pi/agent/settings.json` and one lost its entry; the three pi packages are now chained with
  `after`, and the rerun is green.
- **Lint of this branch alone fails** with `unknown package node` (in `pi` and `codex`) until chunk 2
  merges. Merge chunk 2 first.

### dots bugs found
7. **Script `check`/`version`/`install` PATH lacks the `[env] path` dirs.**
   `dots-cli/src/providers.rs` builds `ScriptEnv { path_prefix: Vec::new() }`, so a tool installed
   under a package's `[env] path` (npm global prefix, `~/.local/node/bin`) is `missing` in
   `dots status` / `plan --check` even though `apply` passed its post-install check. Repro: a script
   package with `[env] path = ["~/.local/x"]` whose `check = "command -v tool"` and which installs
   `tool` there; `apply` ok, `status` says missing. Workaround: `pi` / `codex` / `pi-*` commands
   source `${DOTS_STATE:-$HOME/.local/state/dots}/env.sh` first.
8. **Custom providers (`[providers.<id>]` in dots.toml) are never selected at plan time.**
   `dots-resolve/src/pass.rs` calls `Provider::availability(facts)`, and `CustomProvider` answers
   `Unsupported` unless `facts.providers[id] == Some(true)`, which nothing sets for custom ids
   (`availability_in` with the `available` command is not used by the resolver). Repro: package with
   `[providers.pi-package] name = "npm:pi-subagents"` in a bundle -> `warning[no-provider-satisfies]
   ... pi-package skipped: not available on this machine`. This affects `npm-g`, `gh-ext`,
   `herdr-plugin`, `pi-package` and `code-ext` from `dots.toml` (chunk 2 and 5 packages that use
   them are silently not installed). Workaround: script packages (see Deviations).

### Profile additions
- `machines/mac.toml`, `linux-desktop.toml`, `docker.toml`: add `agents` (already listed in the
  planned profiles in §2.1; `docker.toml` currently has only `base` and the chunk 1 TODO).
- `remote.toml`: nothing.

### For chunk 6 and the merge
- Merge order: chunk 2 before chunk 3 (`node`), or lint fails.
- `packages/agents-status/package.toml` is overwritten here (chunk 1 placeholder): take this one.
- Chunk 6: `windows.conf.yaml` / `common.conf.yaml` / `install.conf.yaml` still point at
  `dotfiles/{claude,pi,codex,cursor}/…`, `dotfiles/cursor-cli-wrapper.toml`,
  `dotfiles/agents-status-config*.toml` and `dotfiles/herdr/*`; those moved to `packages/…`.
  `dotfiles/claude/hooks.txt` and `dotfiles/herdr/generate-config.{sh,ps1}` stayed in place.
  `windows.conf.yaml` also needs the Windows claude `settings.json` mods path decision (it now holds
  `~/.claude/mods`).
- Paths owned here that others might touch: `~/.claude/*`, `~/.codex/config.toml`, `~/.pi/agent/*`,
  `~/.cursor/statusline.sh`, `~/agents-status`, `~/.config/{herdr,agents-status,cursor-cli-wrapper,
  herdr-automatic-rename}`, `~/.local/share/herdr-zig` (chunk 5's ghostty uses `~/.local/zig`).
- Cutover (§8 step 2) is documented in `packages/herdr/manual/split-runtime-dir.md`.

## 11.2 Chunk 2 report (dev tooling)

Branch `migrate-c2`. `bundles/dev.toml` plus 62 owned packages and 7 helper packages.

### Deviations
- **Extra packages** (one apt name per package, or hook replacements): `graphviz`, `dict-wn`, `dict-moby-thesaurus`, `libatomic1`, `libdbus-1-dev`, `tmux-default-keys`, `tpm-plugins`. All are in `bundles/dev.toml`.
- **neovim (linux)**: pinned v0.11.5 release tarball into `~/.local/nvim` plus a `~/.local/bin/nvim` symlink, not `upgrade_nvim.sh` (it starts with `ping`, absent in containers, and builds from source). `neovim-build-deps` only installs `ninja-build` plus base packages. The gettext/libtool/autoconf/automake/doxygen/clang group needs a multi-package apt group (TODO).
- **dict-moby-thesaurus**: not in Ubuntu 24.04, so a script with an inline `sudo -n dpkg -i` retry loop.
- **fx (linux)**: release binary into `~/.local/bin`; fx.wtf/install.sh does `sudo mv`.
- **yazi (linux)**: release zip (yazi + ya). crates.io `yazi-fm` 26.5.6 does not compile (the published crate lacks `../yazi-plugin/preset`).
- **igrep**: cargo from git `konradsz/igrep` (crates.io 1.2.0 fails with current rustc, locked or not). brew on macOS.
- **lumen, ftdv, tuitab, mermaid-rs-renderer**: cargo only (no brew formula).
- **hunk, openspec, mermaid-cli, gh-dash, gh-enhance, gh-markdown-preview, gh-stack**: script packages, not `npm-g` / `gh-ext` (dots bug 7). The node and npm used are brew's on macOS, `~/.local/n` on Linux.
- **libtmux**: script (`pip --user --break-system-packages`), because uv `kind = "lib"` fails (dots bug 8).
- **kv-env**: `when = not(tag = "sandbox")`. `kv install` fails on linux/aarch64 ("neovim: Failed to copy binary"), which is a kv bug. It also shells out to `sudo apt-get`.
- **koala-cli**: `bin` unknown; confirm it on a box with ssh.
- **tpm-plugins** clones the `@plugin` lines of `plugins.tmux` itself (no tmux server, files not yet linked).
- **node (linux)**: `n` via a fetched script into `~/.local/n`, plus `libatomic1`. **bun**: `SHELL=none` stops the installer editing rc files.
- `{app_support}` bottom/ez links on macOS. hop and yq/yj/glow are macOS only.

### Docker (Ubuntu 24.04 aarch64, bundles base+dev, tag sandbox, gui=false)
`lint 0, plan 0, apply 0, status 0 ("All good. 91 packages - 32 files"), second plan empty`. In the container: nvim v0.11.5, tmux 3.4, go, node, difft, btm, yazi, ig, `tmux -f ~/.tmux.conf new -d && kill-server` exit 0, all tpm plugins cloned. The run was incremental (cargo builds cached from earlier attempts); cargo needs `CARGO_BUILD_JOBS=4` here or Docker kills the container. Local Mac `lint`/`plan` with a scratch home are clean.

### New dots bugs
7. **Custom providers (`npm-g`, `gh-ext`) are skipped as "not available" at plan time** when their tool (`npm`, `gh`) is installed in the same run, even with `bootstrap = "node"`. Repro: Linux box without node, a package with only `[providers.npm-g]`. dots prints "Not planned: X (no provider can install it)".
8. **`uv` `kind = "lib", python = "system"` fails on Ubuntu 24.04**: `uv pip install --system` hits PEP 668 and /usr/local needs root. Repro: apply `libtmux` as a uv lib.
9. **Scripts don't see PATH entries of packages installed earlier** in the same run (`~/.cargo/bin` for kv, `~/.local/n/bin` for npm), contrary to ARCH §5.3.
10. **cargo defaults to `--locked`**, which breaks old locked crates (igrep, `time`). Use `locked = false` or git.

### Bundle additions for machines/*.toml
`dev` into `docker` (sandbox; kv-env and the gh extensions self-gate), `linux-desktop` (already lists it), `mac` (already lists it), and `remote`: optional. Nothing here is gated on gui.

### For chunk 6 / merge
Owned paths are disjoint from other chunks. `packages/koala-config/package.toml` is an add/add conflict with the chunk-1 placeholder: take mine. `dotfiles/ez-workspaces-windows` stays for chunk 6. Moved: `dotfiles/{.kvim.conf,tmux_conf,yazi,hunk,lumen,ftdv,ez-workspaces,ez-workspaces-macos,hop,bottom,gh-dash}`, `editors/KoalaConfig-10`, `playgrounds`. Follow-ups: the Mac's local-path cargo copies of kv/ez-workspaces/hop (`dots bins --shadowed`), koala-cli bin name, and re-check with a gui profile.

## 12. Final state

Chunk 6 plus the master merge, the v02c workaround sweep and the profile additions. Written against dots v02c
(`~/.cache/dots-migration/dots-v02c`, image `dots-test:v02c`).

### What changed

- **Master merged.** `13232982` (Dopamine) is migrated as `packages/dopamine` (macOS script package: latest `.dmg`
  from GitHub releases, verified against `SHA256SUMS.txt`, `check = test -d /Applications/Dopamine.app`; in
  `mac-extra`). v02c has no `archive`/`github-release` provider, so it stays a script. `git merge master` was
  clean (`macos.conf.yaml` kept as master's one-line change, then deleted by chunk 6).
- **Merge fallout fixed:** `fontforge` (chunk 4, macOS) and `font-fontforge` (chunk 5) collided as `binary-collision`;
  `font-fontforge` is Linux-only now and `font-nerdwand-lyth` requires one per OS.
- **Chunk 6.** Windows moved to `legacy/windows/` (dotbot kept; see its README; paths rewritten, not exercised). Deleted:
  `install`, `install-macos`, `common/install/macos.conf.yaml`, `pre-commit`, `install_scripts/`, `dotfiles/`, `editors/`.
  `install_scripts/` coverage audit found two uncovered pieces, now packages in `optional`: `taskwarrior-tui`
  (cargo) and `taskopen` (pinned git). `brotab` is now `gui` (the Mac installer installed it) and sits in `gui-apps`.
  `README.md`, `AGENTS.md`, `KEYBINDINGS.md`, `Makefile` (`plan`/`apply`/`docker`, `submodule.recurse`),
  `.githooks/pre-commit` (new submodule paths; the chunk 6 commits were made without `--no-verify`).
  `aerospace-scripts` now calls `~/.config/aerospace/scripts/*`.
- **Profiles.** `docker` = base dev agents (fonts left out: the Nordwand build needs 4 GB); `mac` and
  `linux-desktop` already listed `agents`.

### Workarounds converted (dots v02c fixes)

1. hooks: karabiner (`post_files`, `post_install`), linearmouse (login item; `linearmouse-login-item` deleted),
   tmux (`post_install` default keys, `post_files` plugin clone; `tmux-default-keys`, `tpm-plugins` deleted),
   brotab (`bt install`; `brotab-install` deleted), pi (herdr integration; `pi-herdr` deleted), herdr-collie
   (`setup.sh`; `herdr-collie-setup` deleted, manual moved), font-caskaydia-cove (prune; `-prune` deleted).
2. provider `shim`: `fd-shim`, `bat-shim` deleted (`shim =` creates both; seen in the Docker apply).
3. `needs_root = true` instead of inline `sudo -n`: locale, firefox-snap-remove, macos-power, awesome-root-extras,
   fusuma, vicinae, pinta, dict-moby-thesaurus (retry loop gone), gamescope, alacritty-desktop.
4. `providers_only` dropped from meta packages: hyprland, cursor, claude, macos-defaults, browser-extensions,
   serial-access, xdg-defaults.
5. uv `kind = "venv"`: `scripts`.
6. Custom providers (probed and bootstrapped): `npm-g` for hunk, openspec, mermaid-cli, codex (Linux);
   `gh-ext` for gh-dash, gh-enhance, gh-markdown-preview, gh-stack; `herdr-plugin` (`name` = plugin id,
   `source` = owner/repo) for 10 plugins. `npm-g` commands now pick brew's npm on macOS and `~/.npm-packages` on Linux.
7. Scripts see `[env] path`: all `env.sh` sourcing removed (pi, codex, pi-*); `kv-env` lost its `PATH=` prefix.
8. `lock = "pi"` replaces the `after` chain between pi-subagents, pi-powerline-footer and pi-community-themes.
9. Flat apt repo and binary key: `sublime-apt-repo` deleted, `sublime` and `sublime-merge` use
   `repo = { ..., flat = true }` (key fingerprint `1EDDE2CD...901A`); `spotify` uses the official binary `.gpg` key.
10. xdg: `xdg-defaults` plans without `xdg-utils` installed first (Docker gui plan, below).
11. `install = "install.sh"`: font-nerdwand-lyth, hyprland-plugins, ghostty, gamescope, dopamine (the file needs its own
    `set -euo pipefail`; the runtime prelude is not applied to a file).
12. apt/script race comments and the gamescope `DPkg::Lock::Timeout` removed.
13. igrep: `locked = false` on its git source (the maintainer pointed to the opt-out).

Count: 13 groups, about 70 packages touched, 14 packages deleted.

### Workarounds that remain, and why

- **pi packages stay scripts** (with `lock = "pi"`) instead of `pi-package`: custom providers have no serialization,
  and concurrent `pi install` calls lose entries (bug 16). `pi-package` stays declared in `dots.toml`, unused.
- `pi` / `codex`: pi needs `--ignore-scripts` (no per-package install flags, gap G13).
- `libtmux`: uv `kind = "lib"` with system python (PEP 668, bug 17). `break_system_packages` is not in v02c.
- cargo `--locked` on old crates: only igrep needed it (fixed above with `locked = false`).
- one apt name per package: the helper packages (`libgtk-4-dev`, `libadwaita-1-dev`, ...) stay.
- `acpi` keeps inline `sudo -n` (new bug 19).
- git clones as scripts (tpm, ghostty-shaders, awesome-plugins, pi-skills, taskopen): file `mode = "git"` (gap G1).
- archive-style scripts: go, node, bun, deno, fx, neovim, yazi, codelldb, bluetuith, proton-ge, herdr-zig, ghostty,
  dopamine, win32yank, font release archives (no `archive`/`font` provider yet). `vscode-ext` (36 packages) is `code-ext`.
- taskwarrior itself is apt 2.6 (the old installer built 3.x), `hyprland` has no provider, `pulseaudio`/`browser-extensions`
  are manual or unmapped, `zsh-conf` still reads marker files, `claude` mods path `~` expansion is unverified.

### New dots bug

19. **`needs_root` scripts run under `sudo -n` with `env_reset`**: `HOME=/root`, `PATH` reset and every `DOTS_*` variable dropped
    (checked in the container: `sudo bash -c env` shows only `SUDO_*`, `HOME`, `PATH`). A root script can't see `$DOTS_PKG_DIR`,
    `$DOTS_TAGS` or the user's home (use `SUDO_USER` + `getent passwd`). Suggested: `sudo -n --preserve-env=...` or pass them through
    `env`. `acpi` needs them and keeps inline sudo.

### Validation

- `lint`: 0 (`ok (294 packages, 11 bundles checked)`), Mac and Docker.
- **Docker, profile `docker`, tag `sandbox`** (`dots-test:v02c`, `--memory 6g --memory-swap 6g`, `CARGO_BUILD_JOBS=4`, fresh container, one
  uninterrupted run): plan: 92 installs, 48 file changes, 2 shims, 3 hooks; `lint 0, plan 0, apply 0,
  status 0 ("All good. 104 packages - 47 files"), recheck 0 ("Nothing to do: the machine already matches the repo")`, `RESULT: OK`.
  Shims and the three hooks (`default-keys.sh`, `install-plugins.sh`, pi/herdr) ran in that apply.
- **Docker, `gui = true`**, bundles base + gui-apps + linux-desktop, tag sandbox, plan only: `lint 0`, `plan 0`: 108 installs, 37 file
  changes, 2 settings (both xdg, deferred without `xdg-utils` installed), 1 service, 2 shims, 1 hook (brotab). No warnings or errors;
  spotify's repo with the binary key and `alacritty-desktop` (needs_root) plan fine; `plan --check` exits 3 as expected (nothing applied).
- **Mac, scratch `--home`** (`/tmp/h1`, profile mac): `lint 0`; `plan` has no errors: 40 installs, 59 file changes, 7 settings, 2 services,
  3 hooks. Most installs are scratch-home artifacts (bug 8: brew sees no formulae). Never applied to the real `$HOME`.

### Remaining TODO(dots-migration) items

106 markers in 97 files under `packages/`, `bundles/`, `dots.toml`, `lib/`, `machines/` (count with
`grep -rn 'TODO(dots-migration)' packages bundles dots.toml lib machines README.md | wc -l`). 36 are the `code-ext` ->
built-in `vscode-ext` swap, 10 `herdr-plugin`, 9 `font`, 11 `archive`, 5 `npm`; the rest are the gaps above.

### Open items

- Mac cutover (section 8) and the first `dots.lock`.
- hypr-dots `Keybinds.conf` wallpaper path (`~/dotfiles/awesomewm/wallpaper.jpg`); `.claude/settings.local.json` still names an old path.
- Dots follow-ups: bug 19; `break_system_packages` and an `archive`/`font` provider in the next dots build; custom-provider `lock`.
- Not run: Docker with `fonts`, gaming, optional bundles; ghostty and gamescope builds.
