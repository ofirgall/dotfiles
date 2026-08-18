# Manual Setup Steps

Steps that require manual intervention and can't be fully automated.

## Karabiner-Elements Permissions
After first install, grant access in:
- System Settings > Privacy & Security > Input Monitoring
- System Settings > Privacy & Security > Accessibility

## AeroSpace Screen Recording Permission
AeroSpace needs Screen Recording access for `screencapture` keybindings (Cmd+S, Cmd+Shift+S) to work:
- System Settings > Privacy & Security > Screen Recording > enable **AeroSpace**

## aerospace-switcher Accessibility Permission
The window switcher (Ctrl+Tab) needs Accessibility access for keyboard monitoring (Enter/Escape/arrow key handling):
- System Settings > Privacy & Security > Accessibility > add `~/.local/bin/aerospace-switcher`

## Disable macOS Screenshot Shortcuts
`setup_once.sh` disables Cmd+Shift+3/4/5 via `defaults write`. If screenshots still fire (conflicting with AeroSpace workspace binds), disable manually:
- System Settings > Keyboard > Keyboard Shortcuts > Screenshots > uncheck all Cmd+Shift entries

## agents-status Notifications
Grant notification permission to alerter (first run triggers macOS permission prompt):
```bash
alerter --title "Setup" --message "Click Allow" --sound default --timeout 10
```

## Ghostty: Disable Secure Keyboard Entry
Ghostty may hold the macOS Secure Input lock, which prevents AeroSpace from intercepting `alt`-only keybindings (e.g. `alt-v`). `cmd-alt-*` bindings are unaffected.
- In Ghostty: Terminal menu > uncheck **Secure Keyboard Entry**
- To verify: `ioreg -l -w 0 | grep kCGSSessionSecureInputPID` — if a PID appears, that process is holding the lock

## One-time System Setup
```bash
install_scripts/mac/setup_once.sh
```
Requires logout for key repeat changes to take effect.
