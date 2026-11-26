---
id: accessibility
title: Grant aerospace-switcher Accessibility
when: 'os = "macos"'
after: install
revision: 1
---

The window switcher (Ctrl+Tab) needs Accessibility access for keyboard monitoring (Enter, Escape, arrows):

System Settings > Privacy & Security > Accessibility > add `~/.local/bin/aerospace-switcher`.
