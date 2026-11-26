---
id: apply-hotkeys
title: Apply keyboard shortcut changes without logout
when: 'os = "macos"'
after: files
revision: 1
---

After the symbolic hotkeys changed (Spotlight, input source, screenshots), either log out or run:

```sh
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
```

If the screenshot shortcuts still fire (conflicting with AeroSpace workspace binds), uncheck them in
System Settings > Keyboard > Keyboard Shortcuts > Screenshots (all Cmd+Shift entries).
Key repeat changes need a logout.

Ghostty and agents-status sections of the old MANUAL.md are in the chunk 4 report.
