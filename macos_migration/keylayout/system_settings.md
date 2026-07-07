# macOS System Settings Changes

## Fast Key Repeat Rate

```bash
defaults write -g InitialKeyRepeat -int 10   # ~166ms delay
defaults write -g KeyRepeat -int 1            # ~16ms between repeats (fastest)
```

Requires logout. Already documented in `macREADME/MANUAL.md`.

## Language Switching (English/Hebrew)

- **Linux**: `Mod4+Space` via AwesomeWM keyboard_layout widget
- **macOS**: System Settings > Keyboard > Keyboard Shortcuts > Input Sources
- Assign to Ctrl+Space or Cmd+Space (depends on open decision about Cmd+Space vs Spotlight)

## Disable Conflicting System Shortcuts

In **System Settings > Keyboard > Keyboard Shortcuts**, disable shortcuts that conflict with Aerospace:

| Shortcut | Category | Reason |
|---|---|---|
| Cmd+H | App Shortcuts (hide) | Conflicts with Aerospace focus-left |
| Cmd+M | App Shortcuts (minimize) | Conflicts with Aerospace maximize-toggle |
| Cmd+Space | Spotlight | Conflicts with language switching (if used) |

Some of these may be intercepted by Aerospace without needing to disable them in System Settings. Test each one as it's configured and log results in `macREADME/KEY_CONFLICTS.md`.
