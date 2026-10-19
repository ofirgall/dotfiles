## 1. Plugin repo scaffold

- [x] 1.1 Create `~/workspace/personal/herdr-plugins/herdr-notify` git repo (remote `ofirgall/herdr-notify`, pushed) with README and LICENSE
- [x] 1.2 Write `herdr-plugin.toml`: id `herdr-notify`, platforms linux/macos, `min_herdr_version` set to the running herdr, actions `watch` and `cancel` (contexts `global`), events `pane.closed` and `pane.exited`, a `[[startup]]` that clears stale sentinels
- [x] 1.3 Add a shared `lib.sh`: state dir resolution (`${XDG_STATE_HOME:-$HOME/.local/state}/herdr-notify`), `HERDR="${HERDR_BIN_PATH:-herdr}"`, token set/clear helpers (bash 3.2 compatible)

## 2. Actions and events

- [x] 2.1 `watch.sh`: create the sentinel for `$HERDR_PANE_ID` and report token `notify=⏳` (`--source herdr-notify`)
- [x] 2.2 `cancel.sh`: remove the sentinel and clear the token for `$HERDR_PANE_ID`
- [x] 2.3 `cleanup.sh`: read the pane id from `HERDR_PLUGIN_EVENT_JSON` (or `HERDR_PANE_ID`) and remove its sentinel. On startup, remove all sentinels.

## 3. Completion notification

- [x] 3.1 `notify.sh <exit> <cmd>`: remove the sentinel first, clear the token, resolve workspace/tab labels for the pane via herdr CLI, build the title `<ws>|<tab>` and body `<cmd> finished (exit N)`
- [x] 3.2 Send the OS notification (`notify-macos -u critical` → `osascript` fallback on macOS; `notify-send -u critical` on Linux)
- [x] 3.3 Send the herdr toast `herdr notification show "<title>" --body "<body>" --sound done`
- [x] 3.4 `shell/herdr-notify.zsh`: `preexec` records the command; `precmd` captures `$?` and, if a command was recorded and the sentinel exists, runs `notify.sh` in the background (`&!`)
- [x] 3.5 Make the hook loadable from a stable path (e.g. startup symlinks it to `~/.local/state/herdr-notify/hook.zsh`), or document how `hooks.zsh` resolves the plugin root

## 4. Dotfiles wiring

- [x] 4.1 `install_scripts/mac/install_herdr.sh`: add an idempotent `herdr plugin install ofirgall/herdr-notify --yes` block
- [x] 4.2 `dotfiles/herdr/common-config.toml`: bind `prefix+m` → `herdr-notify.toggle` (watch/cancel in one key), and add `{token = "$notify"}` to `[ui.sidebar.spaces]` rows
- [x] 4.3 `dotfiles/my-zsh-conf/hooks.zsh`: source the herdr-notify zsh hook when `HERDR_PANE_ID` is set
- [x] 4.4 Regenerate the config (`generate-config.sh mac`) and run `herdr config check`

## 5. Verify

- [x] 5.1 `herdr plugin link` the dev checkout. Watch a pane running `sleep 10`: the token appears, then on completion both notifications appear with the right exit code and the token clears.
- [x] 5.2 Watch an idle prompt, then run a command: exactly one notification, after it finishes
- [x] 5.3 Cancel mid-command: no notification, token cleared
- [x] 5.4 Close a watched pane: sentinel removed
- [x] 5.5 Shell startup time inside herdr is not noticeably affected
