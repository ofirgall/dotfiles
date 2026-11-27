---
id: login-item
title: Start LinearMouse at login (click Allow for System Events)
when: 'os = "macos"'
after: install
check: 'osascript -e "tell application \"System Events\" to exists login item \"LinearMouse\"" 2>/dev/null | grep -qx true'
revision: 1
---

LinearMouse does not add its own login item, and adding one through System Events needs a
one-time Automation consent that only a person can click. At the Mac, in a terminal, run:

```sh
osascript -e 'tell application "System Events" to if not (exists login item "LinearMouse") then make login item at end with properties {path:"/Applications/LinearMouse.app", hidden:true}'
```

macOS asks whether your terminal may control **System Events**: click **Allow** (or turn it on
in System Settings > Privacy & Security > Automation, then run the command again). Or skip the
command: System Settings > General > Login Items > **+** > LinearMouse.

The check closes this once the login item exists (`dots todo check`).
