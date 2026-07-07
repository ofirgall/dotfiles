# Key Layout Strategy

Replicate the Linux keyboard experience on macOS: **Ctrl for terminal, Alt for tmux, Super for WM**.

## The Problem

On Linux, three modifier keys have clean, separate roles:
- **Ctrl** -- terminal programs (nvim, shell) + Ctrl+Shift+C/V for terminal copy/paste + Ctrl+C/V for GUI copy/paste
- **Alt** -- tmux control (Ctrl+b prefix, but Alt+Shift+{letter} for navigation binds)
- **Super** -- window/workspace management (Hyprland/AwesomeWM)

On macOS, the physical keyboard layout and OS conventions differ:
- The key positions are **Fn | Ctrl | Option | Cmd | Space** (vs PC's **Ctrl | Super | Alt | Space**)
- macOS uses **Cmd** for what Linux uses Ctrl for (Cmd+C, Cmd+V, Cmd+Tab, Cmd+Q)
- **Option** types special characters instead of acting as Alt

## Target: Physical Layout After Remapping

### Built-in MacBook Keyboard

Remap so the physical keys match PC muscle memory:

| Physical Key | Sends | Role |
|---|---|---|
| Fn/Globe (bottom-left) | **Left Ctrl** | Terminal programs, nvim |
| Left Ctrl | **Fn** | Function keys |
| Left Option | **Left Cmd** | Super for Aerospace WM |
| Left Cmd | **Left Option** | Alt for tmux (via Ghostty `macos-option-as-alt`) |
| CapsLock | **Escape** | Vim escape (already done) |
| Right Option | **Backspace** | Quick delete (from `xmodmaprc`) |

After this, the bottom row reads: **Ctrl | Super(Cmd) | Alt(Option) | Space** -- identical to a PC.

### ZSA Voyager

No Karabiner remapping. QMK firmware handles everything. Karabiner rules must **exclude** the Voyager by device vendor/product ID (ZSA vendor ID: `0x3297`).

### Non-QMK External Keyboards (second priority)

Same Cmd↔Option swap as built-in. Done as default Karabiner behavior with Voyager excluded, or with per-device rules.

## Layer Architecture

```
Physical Keyboard ──► Karabiner-Elements (Layer 2: OS-level remap)
                              │
Voyager QMK ─────────────────►│
  (Layer 1: firmware)         ▼
                         macOS (Layer 3: OS shortcuts)
                              │
                              ▼
                    Aerospace (Layer 4: WM intercepts)
                              │
                              ▼
                    Application (Layer 5: Ghostty, Browser, etc.)
```

- **Layer 1 (QMK)** -- Voyager firmware handles its own layout
- **Layer 2 (Karabiner)** -- physical key swaps + context-aware Ctrl→Cmd remapping
- **Layer 3 (macOS)** -- receives remapped keys, handles Cmd+Tab, system shortcuts
- **Layer 4 (Aerospace)** -- intercepts Cmd-based WM shortcuts before apps see them
- **Layer 5 (Apps)** -- Ghostty's `macos-option-as-alt` converts Option to Alt for terminal use

## Detailed Tool Plans

- [karabiner.md](karabiner.md) -- Karabiner-Elements remapping rules
- [aerospace.md](aerospace.md) -- Aerospace WM keybind mapping
- [ghostty.md](ghostty.md) -- Ghostty terminal keybind changes
- [system_settings.md](system_settings.md) -- macOS system settings changes

## Open Decisions

1. **Cmd+Space**: Use for language switching (like Linux Super+Space) or keep for Spotlight? If language switching, need alternate Spotlight binding (or replace Spotlight with Raycast).
2. **Cmd+Q behavior**: Close window (Aerospace) or quit app (macOS)? On Linux, Super+Q closes the window. May want both: Aerospace cmd+q to close window, cmd+shift+q to quit app.
3. **Alt+Tab scope**: Should Aerospace's alt-tab cycle windows across all workspaces or only the current one? AwesomeWM's Alt+Tab cycles focus history on the current tag.
