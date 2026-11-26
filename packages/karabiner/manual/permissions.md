---
id: permissions
title: Launch Karabiner-Elements and grant Input Monitoring + Accessibility
when: 'os = "macos"'
after: install
revision: 1
---

1. `open -a Karabiner-Elements`
2. System Settings > Privacy & Security > **Input Monitoring**: enable `karabiner_grabber` and `karabiner_observer`.
3. System Settings > Privacy & Security > **Accessibility**: enable Karabiner-Elements.
4. If the remaps do not load after a config change: `touch -h ~/.config/karabiner/karabiner.json`.
