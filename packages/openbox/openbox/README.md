# Openbox Config

Minimal gaming-focused Openbox setup (single desktop named "Gaming").

## Keybindings

| Key               | Action              |
| ----------------- | ------------------- |
| `Super+Return`    | Open terminal       |
| `Super+Q`         | Close window        |
| `Super+F`         | Toggle fullscreen   |
| `Super+M`         | Toggle maximize     |
| `Super+Shift+E`   | Exit Openbox        |
| `XF86Audio*`      | Volume up/down/mute |

## Mouse

| Input              | Action                  |
| ------------------ | ----------------------- |
| `Alt+Left click`   | Focus/raise, drag=move  |
| `Alt+Right click`  | Focus/raise, drag=resize|
| `Right click`      | Desktop menu            |

## Window Switching

**Not currently configured.** Add `A-Tab` / `NextWindow` keybinding to `rc.xml` to enable Alt-Tab cycling.

## Window Rules

| App           | Rules                    |
| ------------- | ------------------------ |
| Steam         | No decorations           |
| Rocket League | No decorations, fullscreen |

## Theme

Bear2, 9pt bold sans title font, layout: `NLIMC` (icoN, Label, Iconify, Maximize, Close).

## Rocket League Launch Options

```
DXVK_ASYNC=1 RADV_PERFTEST=gpl gamescope -w 1440 -h 1080 -r 144 -f -S stretch --force-grab-cursor -- gamemoderun %command%
```

- `DXVK_ASYNC=1` — async shader compilation (reduces stutter)
- `RADV_PERFTEST=gpl` — enables RADV graphics pipeline library
- `gamescope` — Valve's micro-compositor (resolution scaling, frame limiting, input latency)
  - `-w 1440 -h 1080` — game renders at 4:3 (stretched res)
  - `-r 144` — refresh rate limit (match your monitor)
  - `-f` — fullscreen
  - `-S stretch` — stretches 4:3 to fill display (no black bars)
  - `--force-grab-cursor` — locks cursor inside window
- `gamemoderun` — Feral GameMode (CPU governor, scheduler priority, GPU clocks)

Set in-game resolution to match `-w`/`-h` (1440x1080). Mismatched resolutions cause double scaling or black bars.

## Files

- `rc.xml` — main config (keybinds, mouse, theme, window rules)
- `autostart` — programs launched on session start
