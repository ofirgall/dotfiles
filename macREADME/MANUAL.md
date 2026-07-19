# Manual Setup Steps

Steps that require manual intervention and can't be fully automated.

## Karabiner-Elements Permissions
After first install, grant access in:
- System Settings > Privacy & Security > Input Monitoring
- System Settings > Privacy & Security > Accessibility

## AeroSpace Screen Recording Permission
AeroSpace needs Screen Recording access for `screencapture` keybindings (Cmd+S, Cmd+Shift+S) to work:
- System Settings > Privacy & Security > Screen Recording > enable **AeroSpace**

## agents-status Notifications
Grant notification permission to alerter (first run triggers macOS permission prompt):
```bash
alerter --title "Setup" --message "Click Allow" --sound default --timeout 10
```

## One-time System Setup
```bash
install_scripts/mac/setup_once.sh
```
Requires logout for key repeat changes to take effect.
