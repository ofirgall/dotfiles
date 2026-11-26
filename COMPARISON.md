# Docker vs this Mac: versions and configs after the dots migration

Written 2026-11-26 by the final verifier. It compares the `migrate-to-dots` branch, applied from scratch in Ubuntu
24.04 Docker (profile `docker`, tag `sandbox`, `gui = false`), with the live Mac, which still runs the dotbot setup
from `~/dotfiles` `master@78df18f4`. The Mac was only read: no `dots apply`, and no secrets or credential files were
opened. The tables below are the Mac parity checklist from MIGRATION.md §7.3, plus every package in the `docker`
profile that provides a `bin`.

## Summary

The Docker run passed: `lint 0, plan 0 (92 installs, 48 file changes, 2 shims, 3 hooks), apply 0, status 0
("All good. 104 packages - 47 files"), recheck 0`, `RESULT: OK`. It took about 33 minutes. `dots bins --shadowed`
reports nothing, and `git config --get-regexp '^url\.'` is empty in the sandbox, as intended.

Passing doesn't mean the result works. `dots status` checks packages through dots' own env, but five of the issues
below only show up in a real shell or a real config load.

| Class | Versions | Configs | Total |
|---|---:|---:|---:|
| match | 16 | 16 | 32 |
| expected difference | 56 | 9 | 65 |
| unexpected difference | 3 | 5 | 8 |
| missing in Docker (gated or failed) | 4 | 1 | 5 |
| missing on Mac (declared, not installed here) | 15 | 0 | 15 |
| **total rows** | **94** | **31** | **125** |

There are six distinct unexpected issues (U1 to U6, details below). U1 to U4 are high or medium severity:

1. **U1: no `dots env` block in `~/.zshenv` on Linux.** In a fresh zsh, go, node, npm, bun, deno and pi are not on
   `PATH`. codex, hunk, openspec and mmdc are on `PATH` but fail with `/usr/bin/env: 'node': No such file`.
2. **U2: herdr builds the fork's default branch (0.8.2), not `fork-v0.9.x` (0.9.5 on the Mac).** herdr 0.8.2
   rejects the config, so herdr runs on defaults.
3. **U3: `~/.codex/config.toml` is never deployed.** The codex package has no `[[files]]` entry.
4. **U4: the branch is missing master commit `78df18f4`** (herdr `[session.resume_executable]`).

## Version table

Mac paths are what `zsh -lic` resolves. Docker paths come from `bash -lc` with `~/.local/state/dots/env.sh`
sourced, because without it the tools in U1 are not found at all. "n/a" means the package's `when` excludes that
platform.

| Tool | Mac | Docker | Source (Mac / Docker) | Class |
|---|---|---|---|---|
| zsh | 5.9 | 5.9 | system / apt | match |
| git | 2.54.0 (Apple Git-157) | 2.43.0 | `/usr/bin` system (brew `git` declared, not installed) / apt **without** the declared `git-core` PPA | unexpected (U6) |
| delta | 0.19.2 | 0.22.0 | cargo / cargo | expected (the Mac build is older) |
| difft | 0.69.0 | 0.72.0 | cargo / cargo | expected |
| rg | 15.1.0 | 14.1.0 | brew / apt | expected (source) |
| fd | 10.4.2 | 9.0.0 (`fdfind` + dots shim `~/.local/bin/fd`) | brew / apt | expected (source) |
| bat | 0.26.1 | 0.24.0 (`batcat` + shim) | brew / apt | expected (source) |
| fzf | 0.74.0 | 0.44.1 apt; zsh resolves zinit's 0.75.0 first | brew / apt (+ zinit) | expected (source) |
| jq | 1.8.2 | 1.7.1 | brew / apt | expected (source) |
| vim | 9.1 | 9.1 | system / apt | match |
| curl | 8.7.1 | 8.5.0 | system (brew not installed) / apt | expected (source) |
| wget | not installed | 1.21.4 | – / apt | missing on Mac |
| unzip | 6.00 | 6.00 | system / apt | match |
| make (build-essential) | GNU Make 3.81 (Xcode) | 4.3 | system / apt | expected (platform) |
| cmake | not installed | 3.28.3 | – / apt | missing on Mac |
| pkg-config | 3.0.2 (pkgconf) | 1.8.1 | brew / apt | expected (source) |
| sponge (moreutils) | not installed | present | – / apt | missing on Mac |
| pcregrep | n/a (Linux only) | 8.39 | – / apt | expected (platform) |
| daemon | n/a (Linux only) | 0.8.4 | – / apt | expected (platform) |
| toilet | not installed | 0.3 | – / apt | missing on Mac |
| sqlite3 | 3.51.0 | 3.45.1 | system / apt | expected (source) |
| svn (subversion) | not installed | 1.14.3 | – / apt | missing on Mac |
| python3 | 3.15.0 | 3.12.3 | brew / apt | expected (source; the minor version gap matters for uv `kind=lib`) |
| ipython3 | 9.17.1 | 8.20.0 | brew / apt | expected (source) |
| brew | 7.0.16 | n/a | script / – | expected (platform) |
| cargo / rustc | 1.97.0 | 1.100.0 | brew `rust` / rustup (decision 13) | expected (source) |
| uv | 0.13.7 | 0.13.10 | brew / astral script | expected (source) |
| locale-gen (locales) | n/a | present | – / apt | expected (platform) |
| win32yank | n/a (wsl) | n/a (wsl) | – / – | expected (gated on `wsl`) |
| kv | 0.2.0 | 0.2.0 | cargo path build / cargo | match |
| nvim | 0.12.4 | 0.11.5 | brew / release tarball pinned to 0.11.5 | expected (deliberate pin; Docker is one minor version behind) |
| ninja (neovim-build-deps) | n/a | 1.11.1 | – / apt | expected (platform) |
| tree-sitter | 0.27.0 (kvim env) | 0.27.2 | kvim env / cargo | expected |
| lemmy-help | 0.11.0 | 0.11.0 | cargo / cargo | match |
| dictd (nvim-dict) | n/a | 1.13.1 | – / apt | expected (platform) |
| deno | not installed | 2.9.8 | – / script | missing on Mac |
| plantuml | not installed | 1.2020.02 | – / apt | missing on Mac |
| dot (graphviz) | not installed | 2.43.0 | – / apt | missing on Mac |
| koala (koala-cli) | not installed | n/a | – / gated `not(tag = "sandbox")` | missing in Docker (gated); not on the Mac either |
| codelldb | n/a (Linux only) | 1.12.3 (no `--version` flag) | – / script | expected (platform) |
| tmux | 3.7b | 3.4 | brew / apt | expected (deliberate: MIGRATION §3 row `install_tmux.sh`; the old Linux installer built the latest from source). The conf loads with no errors on 3.4 |
| ruby | 2.6.10 | 3.2.3 | system (brew not installed) / apt | expected (source) |
| go | 1.26.5 | 1.27.4 | brew / script | expected (but see U1: not on the zsh `PATH`) |
| node | 26.12.1 | 26.13.1 | brew / script (`~/.local/n`) | expected (but see U1) |
| npm | 11.20.0 | 11.20.0 | brew / script | match |
| bun | 1.4.0 | 1.4.5 | brew / script | expected (but see U1) |
| fx | 39.2.0 | 40.0.2 | brew / script | expected |
| btop | 1.4.7 | 1.3.0 | brew / apt | expected (source) |
| btm (bottom) | 0.14.4 | 0.15.0 | cargo / cargo | expected |
| dust | 1.2.4 | 1.2.8 | cargo / cargo | expected |
| jless | 0.9.0 | 0.9.0 | cargo / cargo | match |
| ig (igrep) | 1.2.0 | 1.3.0 | cargo / cargo (`locked = false`) | expected |
| broot | not installed | 1.62.0 | – / cargo | missing on Mac |
| tuitab | 0.4.3 | 0.11.3 | cargo / cargo | expected (the Mac install is old) |
| lumen | not installed | 2.32.0 | – / cargo | missing on Mac |
| ftdv | not installed | 0.1.2 | – / cargo | missing on Mac |
| hunk | not installed | 0.25.0 | – / npm-g | missing on Mac |
| yazi / ya | 26.5.6 | 26.9.1 | brew / script | expected (source). Mac note: `yazi --version` on the Mac fails with `TOML parse error ... "$schema" ... must be a kebab-cased string` on the shared keymap. The same config loads on Docker's 26.9.1, so the Mac's brew yazi needs an upgrade |
| yq | 4.53.3 | n/a in dots (zinit gives 4.54.3 in zsh) | brew / zinit | expected (macOS-only package; zsh-conf supplies it on Linux) |
| yj | 5.1.0 | n/a in dots (zinit gives 5.1.0) | brew / zinit | expected (same as yq) |
| ez | 1.0.0 | 1.0.0 | cargo path build / cargo | match |
| hop | 0.3.0 | n/a | brew / – | expected (macOS-only) |
| cargo-audit | 0.22.2 | 0.23.0 | cargo / cargo | expected |
| cargo-nextest | 0.9.148 | 0.9.152 | brew / cargo | expected |
| comrak | 0.54.0 | 1.2.0 | cargo / cargo | expected (major version gap; the Mac is old) |
| lazydiff | 0.1.0-alpha.18 | 0.1.0-alpha.18 | cargo / cargo | match |
| mmdr | 0.3.1 | 0.3.1 | cargo / cargo | match |
| eza | 0.23.5 | 0.23.5 (zsh resolves zinit's copy first) | brew / cargo (+ zinit) | match |
| just | 1.59.0 | 1.21.0 | brew / apt | expected (source; a large gap) |
| tree | 2.3.2 | 2.1.1 | brew / apt | expected (source) |
| fzy | 1.1 | 1.0 | brew / apt | expected (source) |
| glow | 2.1.2 | n/a | brew / – | expected (macOS-only) |
| sgpt (shell-gpt) | not installed | **broken**: `ModuleNotFoundError: No module named 'click'` | – / uv | unexpected (U5); also not on the Mac |
| mkdocs | not installed | 1.6.1 | – / script (uv) | missing on Mac |
| ranger (ranger-fm) | not installed | 1.9.4 | – / uv | missing on Mac |
| openspec | 1.14.3 | 2.2.0 | brew npm / npm-g | expected (major version gap; the Mac is behind) |
| mmdc (mermaid-cli) | 11.16.0 | 12.2.0 | brew npm / npm-g | expected (major version gap) |
| gh | 2.96.0 | 2.45.0 | brew / Ubuntu apt | expected (source). The gap is large; GitHub's own apt repo would close it |
| gh extensions | dash 4.25.2, enhance 0.6.1, markdown-preview, stack 0.1.1 | none | gh-ext / gated | missing in Docker (gated `not(tag = "sandbox")`: no `gh auth`) |
| claude | 2.1.332 | 2.1.332 | native installer / script | match |
| claude-swap / cswap | 0.29.0 | 1.2.0 | uv / uv | expected (major version gap; the Mac is behind) |
| graphify | 0.9.55 | 0.9.120 | uv / uv | expected |
| codex | 0.167.0 | 0.172.0 | brew cask / npm-g | expected (source; see U1 and U3) |
| cursor-agent | 2026.11.13 | 2026.11.22 | script / script | expected |
| pi | 1.5.0 | 1.6.1 | brew npm / script (`~/.local/n`) | expected (see U1) |
| pi packages | pi-subagents, pi-powerline-footer, pi-community-themes | same 3 | pi / script | match |
| alerter | 26.5 | n/a | brew / – | expected (macOS-only) |
| agents-status | uv 0.1.0 | uv 0.1.0 | uv / uv | match |
| cursor-cli-wrapper | present | present | script / script | match |
| zig (zig-0.15) | brew zig 0.16.0 (undeclared); `~/.local/share/zig-0.15` absent | 0.15.2 in `~/.local/share/zig-0.15` (`$ZIG`; not on `PATH` by design) | brew / script | missing on Mac (zig-0.15) |
| herdr | 0.9.5 | **0.8.2** | cargo path build of `~/workspace/personal/herdr` @ `fork-v0.9.x` / cargo git `ofirgall/herdr` default branch @ `b74e0bb` | unexpected (U2) |
| herdr-last-tab | present | present | cargo path / cargo path | match |
| herdr plugins | 12 installed | none | herdr-plugin / gated | missing in Docker (gated `not(tag = "sandbox")`; collie is also `os = "macos"`) |
| kv-env | Mac kvim envs present | n/a | script / gated | missing in Docker (gated `not(tag = "sandbox")`) |

## Config table

Home paths were normalised (`/home/dev` and `/Users/ofirg` to `~`) before diffing. Directories were compared by
per-file hashes.

| File | Result | Notes |
|---|---|---|
| `~/.gitconfig` | expected | `git config --list` is identical in keys and values, except the two sandbox-gated `url.*.insteadOf` rewrites (bitbucket, github). Docker's file is the generated fragment (git + delta + difftastic), and `core.pager = delta` comes from it |
| `~/.gitignore_global` | match | identical to the repo source |
| `~/.zshrc` | expected | Docker has only the `dots:zsh` block, which sources `entrypoint.zsh` (the same as the Mac's first line). The Mac also has the drift asdf/uv blocks and the postgres `PATH` line, which are local work tooling and stay out of the repo by design |
| `~/.zshenv` | **unexpected (U1)** | Mac: a symlink to `zsh-conf/env.zsh`. Docker: a real file with the `dots:zsh` block that sources the same `env.zsh` (equivalent), **but no `dots env` block**, which decision 4 requires. That block was written to `~/.bashrc`, after the non-interactive `return` |
| `~/.zsh-conf/` | match | identical tree (same submodule commit `c26bb83`) |
| `~/.my-zsh-conf/` | expected | `aliases.zsh`: only the §4.3 path rewrites (`nv-10`, `btmf`, `cdn`, `cdt`, `mode-*`). `env.zsh`: `source ~/secrets.zsh` is now guarded with `[[ -f ]]` (decision 17) |
| `~/.tmux.conf` | match | identical |
| `~/.tmux_conf/` | match | identical tree |
| `~/.tmux/custom-macros` | match | link to the same file. tpm plugins (extrakto, better-mouse-mode) were cloned by the hook |
| `~/.config/nvim` | expected | same submodule commit `1bed7ca`. The Mac has uncommitted edits (`lazy-lock.json`, `lua/plugins/ui.lua`) and an untracked `.kvim.conf` in the checkout |
| `~/.kvim.conf` | match | identical |
| `~/.config/herdr/config.toml` | **unexpected (U4)**, plus expected rewrites | Parsed TOML is equal except: `keys.command` (the 3 deliberate §4.3 rewrites: explain-agent, read-agent-ansi, `dots apply herdr --files-only`) and **`session.resume_executable` missing in Docker** (master `78df18f4` was never merged). The mac layer isn't applied on Linux (expected). Mac note: the live Mac file also lacks `mac.toml`'s `[terminal] default_shell = "zsh"`, so it was generated without that layer, and the Mac's herdr 0.9.5 binary warns `unknown config key session.resume_executable` |
| `~/.config/herdr/config-dev.generated.toml` | **unexpected (U4)**, plus expected rewrites | Same two semantic differences as `config.toml`. The line count differs (456 vs 315) only because yq dropped comments; the parsed TOML is equal otherwise |
| `~/.config/herdr/{agent-detection,scripts}` | expected | scripts are identical. `agent-detection/Makefile` points at `../scripts/record-agent-detection.sh` (the scripts moved into `scripts/`) |
| `herdr config check` | **unexpected (U2)** | Docker's herdr 0.8.2: `config parse error: TOML parse error at line 332 ... data did not match any variant of untagged enum RawSidebarToken; using defaults`. The Mac's 0.9.5 parses it |
| terminfo | match | `herdr-256color.terminfo` defines `xterm-256color` (undercurl), compiled to `~/.terminfo/x/xterm-256color` on Linux, and the Mac has the same entry. The §7.1 check `infocmp -x herdr-256color` is wrong in MIGRATION.md: it fails on both machines because no entry has that name. `tmux-256color` works in Docker |
| `~/.config/bat` | match | absent on both (no bat config in the old repo or the new one) |
| `~/.ripgreprc` | match | identical |
| `~/.config/yazi/` | match | identical tree (see the yazi version note: Mac yazi 26.5.6 can't parse it) |
| `~/.claude/settings.json` | expected | only the mods path differs: `~/dotfiles/dotfiles/claude/mods` became `~/.claude/mods` (§4.3). Whether Claude expands `~` there is still unverified (§12) |
| `~/.claude/keybindings.json` | match | identical |
| `~/.claude/statusline-command.sh` | match | identical |
| `~/.pi/agent/settings.json` | match | identical |
| `~/.pi/agent/keybindings.json` | match | identical |
| `~/.codex/config.toml` | **unexpected (U3)** | the Mac links it to `dotfiles/codex/config.toml`. Docker has no file: `packages/codex/config.toml` exists (identical to the Mac's) but no `[[files]]` entry deploys it |
| `~/.config/agents-status/config.toml` | match | identical |
| `~/.config/gh-dash/config.yml` | missing in Docker (gated) | the gh-dash package is `not(tag = "sandbox")`, so its file isn't deployed. The source is identical to the Mac's |
| `~/.config/hop/config.toml` | expected | hop is macOS-only. The source is identical to the Mac's |
| `bottom.toml` | match | identical (Mac: `{app_support}/bottom`; Linux: `~/.config/bottom`) |
| ez `config.toml` | expected | a platform file (`ez-workspaces/linux/config.toml` vs `macos/config.toml`), both carried over verbatim. Note: the Linux file hardcodes `/home/ofirg/workspace/...` and `on_enter = "tmux"`. This was already true before the migration, but it's wrong for any user other than `ofirg` |
| `~/.profile` / `~/.bashrc` | expected | Linux-only. `~/.profile` is linked from `packages/profile/profile` |

## Unexpected differences

### U1: no `dots env` block in `~/.zshenv` on Linux (high)

- **Symptom.** In a fresh `zsh -i` in the container, `command -v node go bun deno pi` finds nothing. codex, hunk,
  openspec and mmdc resolve through `~/.npm-packages/bin` (added by `env.zsh`), but they fail with
  `/usr/bin/env: 'node': No such file or directory`. `dots status` still says "ok", because dots probes through its
  own env.
- **Cause.** dots chooses the rc file for its env block from `$SHELL`, then falls back to `facts.shell`
  (`dots-cli/src/files_phase.rs` `shell()`, `dots-env/src/inject.rs` `default_rc`). On a fresh Ubuntu account the
  login shell is bash. dots doesn't `chsh` (`packages/zsh/manual/default-shell.md`), so the block lands in
  `~/.bashrc`, below Ubuntu's `case $- in *i*) ;; *) return;; esac` guard. The guard also hides it from
  `bash -lc`. Decision 4 assumed the block would be in `~/.zshenv`. On the Mac, `$SHELL` is zsh, so this only
  happens on Linux, but there it happens on every fresh box, not just in Docker.
- **Files.** `packages/zsh/zshenv.inject`, `packages/zsh/package.toml`.
- **Suggested fix (repo).** Add the env line to `zshenv.inject` before the `env.zsh` source:
  `[ -f "$HOME/.local/state/dots/env.sh" ] && . "$HOME/.local/state/dots/env.sh"`. zsh then gets dots' `PATH`
  whatever `$SHELL` was when apply ran. Optionally also set `[facts] shell = "zsh"` in the Linux machine files.
- **Suggested fix (dots).** Let `facts.shell` from the machine file override `$SHELL`, or inject into every shell rc
  that dots manages. Also put the bash block above the interactive guard, or in `~/.profile`.

### U2: herdr is built from the fork's default branch, 0.8.2 instead of 0.9.5 (high)

- **Symptom.** Docker installs `herdr 0.8.2 (git+https://github.com/ofirgall/herdr#b74e0bb)`.
  `herdr config check` rejects the deployed config (parse error at line 332, `RawSidebarToken`), so herdr starts
  with defaults: no theme, keys or sidebar rows. The Mac runs 0.9.5, built from `~/workspace/personal/herdr` on
  branch `fork-v0.9.x` (pushed to `origin/fork-v0.9.x`).
- **File.** `packages/herdr/package.toml` (`[providers.cargo] git = "https://github.com/ofirgall/herdr"`, with no
  branch).
- **Suggested fix.** Add `branch = "fork-v0.9.x"` (or a `rev`) to `[providers.cargo]`. Bump `zig-0.15` together
  with it if 0.9.x needs a different `minimum_zig_version`.

### U3: `~/.codex/config.toml` is never deployed (medium)

- **Symptom.** `~/.codex/` in Docker holds only `tmp/`. The Mac links `~/.codex/config.toml` to the repo.
- **Cause.** Chunk 3 moved `dotfiles/codex/config.toml` to `packages/codex/config.toml`, but
  `packages/codex/package.toml` never got a `[[files]]` entry. It has none in either commit that touched it
  (`87aa6082`, `94fcad97`). MIGRATION §3 (`codex / link`) and §5 chunk 3 step 7 ("link config") both expect one.
- **File.** `packages/codex/package.toml`.
- **Suggested fix.** Add the following. Codex rewrites `config.toml` (for trust entries, for example), so keep it
  a `link`, per decision 6.

  ```toml
  [[files]]
  src = "config.toml"
  dst = "~/.codex/config.toml"
  ```

### U4: master commit `78df18f4` is not on the branch (medium)

- **Symptom.** The Mac's `~/dotfiles` is at `78df18f4` ("herdr: resume claude through cswap inside kv"), which adds
  `[session.resume_executable] claude = ["cswap"]` to `herdr/common-config.toml`. Neither herdr render in Docker
  has it. §12 says master was merged at `13232982`, which is one commit earlier.
- **File.** `packages/herdr/config/common.toml`.
- **Suggested fix.** Run `git merge master` on `migrate-to-dots` again; the change maps onto `config/common.toml`.
  Section 8 (cutover) should repeat this check right before the switch. Separately, the Mac's installed herdr
  0.9.5 doesn't know the key yet (`unknown config key session.resume_executable`), so reinstall it from the
  current `fork-v0.9.x` HEAD (`66440000`).

### U5: shell-gpt is installed but crashes (low)

- **Symptom.** `sgpt --version` fails with `ModuleNotFoundError: No module named 'click'`. The uv tool env has
  typer 0.29.3 and no click: shell-gpt imports `click` directly, and current typer no longer pulls it in. On the
  Mac, `sgpt` isn't installed at all, so `uv tool list` there shows only agents-status, claude-swap and graphifyy.
- **File.** `packages/shell-gpt/package.toml` (`[providers.uv]` with no options).
- **Suggested fix.** v02c's uv provider has no `with` option. Either switch to `kind = "venv"` with a requirements
  file listing `shell-gpt` and `click`, or add a `post_install` hook:
  `uv tool install --force --with click shell-gpt`.
  Long term, add `with = [...]` to the uv provider. `dots status` should also run the bin, not only read the
  version from uv metadata, so that it catches this kind of failure.

### U6: git's `git-core` PPA is declared but never applied (low)

- **Symptom.** Docker has Ubuntu's git 2.43.0. `/etc/apt/sources.list.d/` has only `ubuntu.sources`. The Mac uses
  Apple git 2.54.0, and brew `git` isn't installed there either.
- **Cause.** `packages/git/package.toml` declares `[providers.apt] repo = { ppa = "git-core/ppa" }`. The image (and
  most fresh Ubuntu installs) already ships git, so dots adopts the existing package and never adds the repo.
- **Suggested fix.** dots: add the declared repo and upgrade when an apt package is adopted and its `repo` is
  missing, or at least warn in `plan`. Repo: until then, add a `version = ">=2.45"` constraint if the provider
  supports it, or document the gap.

## Mac-side observations (not migration bugs)

- **Declared but not installed on the Mac.** Brew formulae `git`, `vim`, `curl`, `ruby`, `unzip` and `sqlite`: the
  system binaries are used today, and a `dots apply` at cutover would install them. Also wget, cmake, moreutils,
  toilet, subversion, deno, plantuml, graphviz, broot, lumen, ftdv, hunk, mkdocs, ranger-fm, shell-gpt, koala-cli
  and zig-0.15. MIGRATION §7.3 lists `shell-gpt`, `mkdocs` and `ranger-fm` as Mac uv tools, but they aren't
  installed now.
- **Undeclared on the Mac.** brew `zig` 0.16.0 is installed but not declared; the repo uses zig-0.15.
- **Mac yazi 26.5.6 is broken.** It fails to parse the shared `keymap.toml` (`"$schema"` key); `brew upgrade yazi`
  should fix it.
- **Mac herdr config.** The live `config.toml` lacks `[terminal] default_shell = "zsh"`, even though
  `mac-config.toml` sets it. A dots render on the Mac will add it.
- **MIGRATION.md §7.1 checks to fix.** `infocmp -x herdr-256color` (no entry has that name); the `go version`,
  `node -v`, `bun --version`, `deno --version` and `pi --version` checks fail in a login shell until U1 is fixed;
  `agents-status --help` (the bin is `agents-status-server`).

## How this was run

Docker command (one fresh run, image `dots-test:v02c`, `dots 0.1.0` v02c build; container removed afterwards):

```sh
docker run -d --name dots-compare --memory 6g --memory-swap 6g -e CARGO_BUILD_JOBS=4 \
  -e DOTS_REPO_PROFILE=docker \
  -v /Users/ofirg/dotfiles-dots:/home/dev/dots-repo:ro dots-test:v02c \
  bash -c '/usr/local/lib/dots-test/repo-test.sh > /home/dev/repo-test.log 2>&1; echo $? > /home/dev/repo-test.rc; exec sleep infinity'
```

`repo-test.sh` wrote `machine.toml` with `profile = "docker"` (`machines/docker.toml`: bundles base, dev and
agents; tag `sandbox`; `gui = false`). Then it ran lint, plan, `apply --yes`, status and `plan --check`. The run
started at 12:45:42Z and finished at 13:18:22Z.

Collection:

- Docker:
  - Versions: `docker exec -u dev dots-compare bash -lc '. ~/.local/state/dots/env.sh; <probe>'`, then the same
    probe under `zsh -lic` without `env.sh`, which found U1.
  - Status: `dots status --all --json` and `dots bins --shadowed`.
  - Files: `docker cp -L` of every config file in the table. Directories were compared as `sha1sum` trees.
- Mac:
  - Versions: the same probe under `zsh -lic`.
  - Files: `cp -L` of the same files into a scratch directory; `git config --file ~/.gitconfig --list` (includes
    not followed, `~/.git_work` not read).
  - Read-only checks: `herdr config check` and `herdr plugin list`.
  - Not read: `~/secrets.zsh`, `~/.git_work`, `auth.json` or any credential file.

## Rerun after U1–U5 fixes (2026-11-26)

Clean Docker run from scratch (`dots-test:v02c`): lint, plan, apply, status and recheck all exit 0, and the second plan is empty.

| Item | Check in container | Result |
|---|---|---|
| U1 zsh PATH | `command -v node go bun deno pi` | all found |
| U2 herdr fork | `herdr --version`, `herdr config check` | 0.9.5, config ok (built with Zig 0.16.0 via `herdr-zig`) |
| U3 codex config | `~/.codex/config.toml` | symlinked from dots |
| U4 master drift | merged master into the branch | done |
| U5 shell-gpt | `sgpt --version` | ShellGPT 1.5.1 |
| U6 git PPA | — | still open (dots-side change needed) |
