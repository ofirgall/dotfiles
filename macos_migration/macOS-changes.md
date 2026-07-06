# macOS Native Changes

Manual system changes that can't be automated via dotfiles/scripts.

## Keyboard

### Key Repeat Rate
```bash
defaults write -g InitialKeyRepeat -int 10
defaults write -g KeyRepeat -int 1
```
Requires logout to take effect.

### Karabiner-Elements Permissions
After first install, grant access in:
- System Settings > Privacy & Security > Input Monitoring
- System Settings > Privacy & Security > Accessibility

## System Settings

(Add manual system tweaks here as needed)
