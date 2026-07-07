# Karabiner-Elements Remapping

Existing config: `dotfiles/mac/karabiner/karabiner.json` (currently only has CapsLock↔Escape swap).

## Simple Modifications (per-device, built-in keyboard only)

| From | To | Notes |
|---|---|---|
| `fn` | `left_control` | Puts Ctrl in bottom-left (PC position) |
| `left_control` | `fn` | Completes the swap |
| `left_command` | `left_option` | Puts Option(Alt) in Cmd position |
| `left_option` | `left_command` | Puts Cmd(Super) in Option position |
| `right_option` | `delete_or_backspace` | Quick backspace (from Linux `xmodmaprc`) |

These use Karabiner's `simple_modifications` with a `device_if` condition matching only the built-in keyboard. The Voyager (vendor ID `0x3297`) must be excluded.

## Complex Modifications

### Rule: "Ctrl shortcuts in GUI apps"

Maps `left_control + {key}` → `left_command + {key}` for common shortcuts, **excluding terminal apps**.

Keys to remap: `c, v, x, z, a, t, w, n, f, tab`

Condition: `frontmost_application_unless` with bundle IDs:
- `com.mitchellh.ghostty`
- `com.apple.Terminal`
- `com.googlecode.iterm2`

This makes Ctrl+C copy in browsers/editors/etc, while raw Ctrl passes through to terminal apps. After the Fn↔Ctrl swap, the user presses the physical **bottom-left key + C** to copy -- feels exactly like Linux.

### Rule: "Option+Tab window switching"

Maps `left_option + tab` → Aerospace window cycling trigger, or simply `left_command + tab` to reuse native macOS app switching.

After Cmd↔Option swap, physical Alt-position key sends Option. So physical "Alt+Tab" = Option+Tab.

Alternative: let Aerospace handle this directly by binding `alt-tab` (which is Option+Tab in Aerospace terms).

## Device Filtering

- Simple modification swaps: `device_if` matching built-in keyboard (and optionally non-QMK externals)
- Voyager excluded via `vendor_id: 0x3297` / `product_id` in `device_unless`
- Complex modifications (Ctrl→Cmd in GUI): apply globally (all keyboards), since the app-level condition is sufficient
