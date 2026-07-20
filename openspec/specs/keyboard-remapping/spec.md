## ADDED Requirements

### Requirement: Karabiner-Elements on macOS
The system SHALL use Karabiner-Elements on macOS for keyboard remapping. The config SHALL live at `dotfiles/mac/karabiner/karabiner.json` (symlinked to `~/.config/karabiner/karabiner.json`). After symlinking, the install SHALL touch the symlink to trigger Karabiner's config reload.

#### Scenario: Karabiner config deployment
- **WHEN** the macOS install completes
- **THEN** `~/.config/karabiner/karabiner.json` SHALL be symlinked and Karabiner SHALL reload via `touch -h`

### Requirement: CapsLock to Escape
CapsLock SHALL be remapped to Escape on both OSes. On macOS, this SHALL be a Karabiner simple_modification. On Ubuntu, this SHALL be configured via xmodmap or Hyprland input config.

#### Scenario: CapsLock behavior
- **WHEN** CapsLock is pressed on either OS
- **THEN** it SHALL send Escape

### Requirement: PC keyboard layout on Mac built-in keyboard
On the MacBook built-in keyboard, Karabiner SHALL apply per-device simple_modifications: Fn↔Left Ctrl (Ctrl in bottom-left, PC position) and Left Cmd↔Left Option (Super in Option position, matching PC layout). These SHALL NOT apply to external keyboards which already have PC layout.

#### Scenario: Key positions on built-in keyboard
- **WHEN** using the MacBook built-in keyboard
- **THEN** physical key order from left SHALL be: Ctrl(was Fn), Super/Cmd(was Option), Alt/Option(was Cmd), Space

#### Scenario: External keyboard unaffected
- **WHEN** using an external keyboard
- **THEN** no key position swaps SHALL be applied (external keyboards already have PC layout)

### Requirement: xmodmap on Ubuntu
On Ubuntu, `~/.xmodmaprc` SHALL be symlinked from `dotfiles/xmodmaprc` for X11 keyboard remapping. For Wayland/Hyprland, keyboard remapping SHALL be handled by the compositor's input config in the hypr-dots submodule.

#### Scenario: xmodmap config
- **WHEN** the Linux install completes
- **THEN** `~/.xmodmaprc` SHALL be symlinked to `dotfiles/xmodmaprc`

### Requirement: macOS system keyboard changes
The install SHALL apply system-level keyboard changes via `install_scripts/mac/setup_once.sh`. These SHALL be documented in `macREADME/SYSTEM_CHANGES.md` and require a logout to take effect (e.g., key repeat rate).

#### Scenario: System changes documentation
- **WHEN** reviewing `macREADME/SYSTEM_CHANGES.md`
- **THEN** all keyboard-related system behavior changes SHALL be listed with method and reason
