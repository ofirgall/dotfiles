# Trackpad Behavior

## Current Setup

- **Tap to Click**: Enabled — single tap = click, double tap = double click
- **Drag style**: "Without Drag Lock" — double-tap and hold on the second tap to drag, lift to stop
- **Acceleration**: Low acceleration (0.65) via LinearMouse (config tracked in `dotfiles/mac/linearmouse/`)
- **Natural scrolling**: Enabled

## How to use

| Action | Gesture |
|--------|---------|
| Click | Single tap |
| Double click | Double tap |
| Right click | Two-finger tap |
| Scroll | Two-finger swipe |
| Drag/select | Physical press + drag, OR double-tap and hold on second tap |
| Select word + extend | Double-tap to select word, then physical press + drag to extend |

## Notes

- "Without Drag Lock" has a small recognition delay before dragging starts. This is a macOS limitation and cannot be removed.
- If the delay is annoying, alternatives:
  - **Physical click + drag** — press the trackpad down and drag (no delay, works like Linux libinput default)
  - **Three Finger Drag** — enable in Accessibility > Pointer Control > Trackpad Options. Instant response, no delay.
- LinearMouse controls trackpad acceleration. Fully disabling acceleration also disables speed control on M-series Macs (Apple limitation). Using low acceleration (0.65) as a compromise.

## Relevant settings locations

- System Settings > Trackpad (tap to click, scroll direction)
- System Settings > Accessibility > Pointer Control > Trackpad Options (dragging style)
- LinearMouse menu bar icon (acceleration, speed)
