## Why

The workflow moved from tmux to herdr, but the "notify me when this command finishes" habit (`prefix+m` via the KoalaVim fork of tmux-notify) did not come along. The zsh hook in `hooks.zsh` only loads tmux-notify inside tmux, so herdr panes have no way to watch a long-running shell command and alert on completion. herdr already provides the needed primitives (plugin actions/events, `herdr notification show`, pane metadata tokens), so a small herdr plugin can replace the subset of tmux-notify that is actually used.

## What Changes

- New herdr plugin `herdr-notify` in its own repo (`ofirgall/herdr-notify`, developed at `~/workspace/personal/herdr-plugins/herdr-notify` and linked with `herdr plugin link`)
  - `watch` action: marks the focused pane as watched (sentinel file + sidebar token)
  - `cancel` action: stops watching the focused pane
  - zsh hook: `preexec` records the command, `precmd` fires the notification for a watched pane and clears the watch
  - Notifications go to the OS (`notify-macos` / `notify-send -u critical`) and to a herdr toast (`herdr notification show --sound done`)
  - `pane.closed` / `pane.exited` events clean up stale watches
- Dotfiles wiring:
  - `install_scripts/mac/install_herdr.sh` installs the plugin
  - `dotfiles/herdr/common-config.toml` binds `prefix+m` (watch) and `prefix+shift+m` (cancel) and adds a `$notify` token to the sidebar
  - `dotfiles/my-zsh-conf/hooks.zsh` sources the plugin's zsh hook when `HERDR_PANE_ID` is set
- Out of scope (deliberately dropped from tmux-notify): refocus variant, configurable message templates, prompt-suffix polling mode, Telegram/Pushover, terminal bell, on-start/on-finish/on-cancel user hooks, agents-status refresh, agent-pane watching

## Capabilities

### New Capabilities

- `herdr-notify`: Watch a herdr pane and notify when the current shell command finishes

### Modified Capabilities

None. No herdr capability spec exists yet; the tmux spec is unchanged (tmux-notify stays for tmux).

## Impact

- New external repo `ofirgall/herdr-notify` (plugin manifest, bash scripts, zsh hook)
- `install_scripts/mac/install_herdr.sh` — one more `herdr plugin install` block
- `dotfiles/herdr/common-config.toml` — two keybindings, one sidebar token
- `dotfiles/my-zsh-conf/hooks.zsh` — source the zsh hook inside herdr
- Runtime state at `~/.local/state/herdr-notify/`
