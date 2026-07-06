# Manual Setup Steps

Steps that require manual intervention and can't be fully automated.

## Karabiner-Elements Permissions
After first install, grant access in:
- System Settings > Privacy & Security > Input Monitoring
- System Settings > Privacy & Security > Accessibility

## Key Repeat Rate
```bash
defaults write -g InitialKeyRepeat -int 10
defaults write -g KeyRepeat -int 1
```
Requires logout to take effect.
