# P1: Keyboard & System Behavior

Goal: Make macOS feel like Linux for keyboard interaction.

## Remaining Items

### Backtick/tilde key (§± → `` ` ``/`~`)
- **Linux source**: Standard PC layout — key left of 1 is `` ` ``/`~`.
- **macOS approach**: Switch input source from "ABC" to "U.S." in System Settings > Keyboard > Input Sources. Also revert Karabiner keyboard type from ISO to ANSI.
- **Status**: [ ] Not started

### Right Alt as Backspace
- **Linux source**: `dotfiles/xmodmaprc` → `keycode 108 = BackSpace`
- **macOS approach**: Karabiner simple modification: `right_option` → `delete_or_backspace`.
- **Status**: [ ] Not started

### Language switching (English/Hebrew)
- **Linux source**: AwesomeWM `Mod4+Space` via echuraev/keyboard_layout widget.
- **macOS approach**: System Settings > Keyboard > Input Sources. Set shortcut to Ctrl+Space.
- **Status**: [ ] Not started
