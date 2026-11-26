# VIA & QMK Feature Reference

## Table of Contents

- [VIA Overview](#via-overview)
- [Mod-Tap (Dual-Role Keys)](#mod-tap-dual-role-keys)
- [Modifier + Key Combinations](#modifier--key-combinations)
- [Layers](#layers)
- [Tap Dance](#tap-dance)
- [Combos](#combos)
- [Key Overrides](#key-overrides)
- [One-Shot Modifiers](#one-shot-modifiers)
- [Space Cadet](#space-cadet)
- [Leader Key](#leader-key)
- [Macros](#macros)
- [Mouse Keys](#mouse-keys)
- [Auto Shift](#auto-shift)
- [Caps Word](#caps-word)
- [VIA Limitations](#via-limitations)

---

## VIA Overview

[VIA](https://www.caniusevia.com/) is a GUI tool for configuring QMK-powered keyboards in real time without reflashing firmware. It supports remapping keys, configuring layers, assigning macros, and more — all through a web or desktop interface.

## Mod-Tap (Dual-Role Keys)

**Supported in VIA: Yes** (via the Any key input field)

Mod-Tap lets a key act as a **modifier when held** and a **regular keycode when tapped**.

Use the `Any` key input in VIA with the **`MT()` generic form**, which is the most reliable syntax across VIA versions:

| Syntax | Hold | Tap |
|--------|------|-----|
| `MT(MOD_LSFT,kc)` | Left Shift | kc |
| `MT(MOD_RSFT,kc)` | Right Shift | kc |
| `MT(MOD_LCTL,kc)` | Left Ctrl | kc |
| `MT(MOD_RCTL,kc)` | Right Ctrl | kc |
| `MT(MOD_LALT,kc)` | Left Alt | kc |
| `MT(MOD_RALT,kc)` | Right Alt | kc |
| `MT(MOD_LGUI,kc)` | Left GUI/Cmd | kc |
| `MT(MOD_RGUI,kc)` | Right GUI/Cmd | kc |

**Example:** `MT(MOD_RSFT,KC_QUOT)` — hold for Right Shift, tap for Quote.

> **Note:** The shorthand aliases (`LSFT_T(kc)`, `RSFT_T(kc)`, etc.) are valid in QMK source code but **may not be recognized by VIA's Any key input**. Always use the `MT(MOD_xxx, kc)` form in VIA.

> **VIA display quirk:** When exporting a layout, VIA may display right-side modifiers differently than entered. For example, `MT(MOD_RSFT,KC_QUOT)` may appear as `MT(MOD_LSFT | MOD_RSFT,KC_QUOT)` after export. This is a VIA decoding artifact — the key still functions correctly. Left and right shift are interchangeable in practice.

### Tuning Parameters (firmware only)

These settings are **not configurable in VIA** — they must be set in QMK firmware source and reflashed:

| Setting | Default | Description |
|---------|---------|-------------|
| `TAPPING_TERM` | 200ms | Time threshold to distinguish tap from hold |
| `PERMISSIVE_HOLD` | off | Registers hold faster when another key is pressed during the tapping term |
| `TAPPING_FORCE_HOLD` | off | Prevents tap on quick press-release-press-hold |
| `RETRO_TAPPING` | off | Sends the tap keycode if no other key was pressed during hold |

## Modifier + Key Combinations

**Supported in VIA: Yes** (via the Any key input field)

Assign a single key to send a modifier + key combination using QMK modifier wrappers:

| Wrapper | Modifier | Example |
|---------|----------|---------|
| `C(kc)` | Ctrl | `C(KC_W)` → Ctrl+W |
| `S(kc)` | Shift | `S(KC_A)` → Shift+A |
| `A(kc)` | Alt | `A(KC_W)` → Alt+W |
| `G(kc)` | GUI/Cmd/Win | `G(KC_L)` → Cmd+L |

Stack wrappers for multi-modifier combos: `C(S(KC_T))` → Ctrl+Shift+T.

## Layers

**Supported in VIA: Yes**

Layers are a core QMK feature fully supported by VIA. Each layer is a complete keymap that overlays the base layer. Transparent keys (`KC_TRNS`) fall through to the layer below.

| Keycode | Behavior |
|---------|----------|
| `MO(n)` | Momentary — activate layer `n` while held |
| `TG(n)` | Toggle — switch layer `n` on/off |
| `TO(n)` | Turn on layer `n` and turn off all other layers |
| `LT(n, kc)` | Layer-Tap — layer `n` on hold, `kc` on tap |
| `OSL(n)` | One-Shot Layer — activate layer `n` for the next keypress only |
| `TT(n)` | Tap-Toggle — momentary on hold, toggle on repeated taps |

## Tap Dance

**Supported in VIA: No** (firmware only; supported by [Vial](https://get.vial.today/))

Tap Dance lets a key do different things depending on how many times it is tapped.

Defined in QMK source via `tap_dance_actions[]`. Example use cases:
- Single tap: `KC_X`, double tap: `KC_Y`
- Single tap: keycode, hold: modifier
- Single tap: keycode, double tap: layer toggle

## Combos

**Supported in VIA: No** (firmware only; supported by [Vial](https://get.vial.today/))

Combos trigger a keycode when two or more keys are pressed simultaneously. Defined in firmware via `combos.def` or `process_combo_event()`.

Example: pressing `J` + `K` together sends `KC_ESC`.

```c
// combos.def
COMBO(jk_combo, KC_ESC, KC_J, KC_K)
```

## Key Overrides

**Supported in VIA: No** (firmware only; supported by [Vial](https://get.vial.today/))

Key Overrides let you change the output of a key when a specific modifier is held. For example, make Shift+Backspace produce Delete without affecting normal Backspace.

```c
const key_override_t shift_bspc = ko_make_basic(MOD_MASK_SHIFT, KC_BSPC, KC_DEL);
```

## One-Shot Modifiers

**Supported in VIA: Yes** (via the Any key input field)

A One-Shot Modifier applies to only the **next keypress**, then deactivates. Useful for reducing finger strain.

| Keycode | Modifier |
|---------|----------|
| `OSM(MOD_LSFT)` | One-Shot Left Shift |
| `OSM(MOD_LCTL)` | One-Shot Left Ctrl |
| `OSM(MOD_LALT)` | One-Shot Left Alt |
| `OSM(MOD_LGUI)` | One-Shot Left GUI |

## Space Cadet

**Supported in VIA: Yes**

Space Cadet keys send a character on tap while acting as a modifier on hold. The classic use case is parentheses on the Shift keys.

| Keycode | Hold | Tap |
|---------|------|-----|
| `KC_LSPO` | Left Shift | `(` |
| `KC_RSPC` | Right Shift | `)` |
| `KC_LCPO` | Left Ctrl | `(` |
| `KC_RCPC` | Right Ctrl | `)` |
| `KC_LAPO` | Left Alt | `(` |
| `KC_RAPC` | Right Alt | `)` |

## Leader Key

**Supported in VIA: No** (firmware only)

The Leader Key starts a key sequence (like Vim's leader). After pressing the leader key, a sequence of keys triggers an action.

```c
// In process_leader:
SEQ_TWO_KEYS(KC_D, KC_D) -> SEND_STRING(SS_LCTL("a") SS_TAP(X_DELETE));
```

## Macros

**Supported in VIA: Partial**

VIA supports basic macros (key sequences) through its Macros tab. For advanced macros with delays, conditional logic, or string output, define them in QMK firmware.

VIA macros can include:
- Key taps and combinations
- Text strings
- Basic delays

## Mouse Keys

**Supported in VIA: Yes** (if enabled in firmware)

QMK can emulate mouse movement, clicks, and scrolling via keyboard keys. The firmware must be compiled with `MOUSEKEY_ENABLE = yes`.

| Keycode | Action |
|---------|--------|
| `KC_MS_U` / `KC_MS_D` | Mouse cursor up / down |
| `KC_MS_L` / `KC_MS_R` | Mouse cursor left / right |
| `KC_BTN1` / `KC_BTN2` | Left click / right click |
| `KC_WH_U` / `KC_WH_D` | Scroll wheel up / down |

## Auto Shift

**Supported in VIA: No** (firmware only)

Auto Shift automatically applies Shift when a key is held slightly longer than a normal tap, eliminating the need to press Shift manually for capital letters and symbols.

Enabled in firmware with `AUTO_SHIFT_ENABLE = yes`. The threshold is configured via `AUTO_SHIFT_TIMEOUT` (default 175ms).

## Caps Word

**Supported in VIA: No** (firmware only)

Caps Word is a smarter Caps Lock that automatically deactivates after typing a word. It stays active while typing letters and underscore, and deactivates on space, enter, or other non-word characters. Useful for typing `CONSTANT_NAMES`.

Enabled in firmware with `CAPS_WORD_ENABLE = yes`, toggled with both Shift keys by default.

## VIA Limitations

While VIA provides convenient real-time configuration, several QMK features require firmware-level changes and a reflash:

| Feature | VIA | Vial | QMK Source |
|---------|-----|------|------------|
| Key remapping | Yes | Yes | Yes |
| Layers | Yes | Yes | Yes |
| Mod-Tap | Yes | Yes | Yes |
| Macros (basic) | Yes | Yes | Yes |
| One-Shot Modifiers | Yes | Yes | Yes |
| Mouse Keys | Yes | Yes | Yes |
| Tap Dance | No | Yes | Yes |
| Combos | No | Yes | Yes |
| Key Overrides | No | Yes | Yes |
| Leader Key | No | No | Yes |
| Auto Shift | No | No | Yes |
| Caps Word | No | No | Yes |
| Tapping Term tuning | No | No | Yes |

[Vial](https://get.vial.today/) is a VIA fork that exposes more QMK features through its GUI. It requires Vial-compatible firmware.
