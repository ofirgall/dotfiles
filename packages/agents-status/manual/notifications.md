---
id: notifications
title: Allow notifications for alerter (agents-status)
when: 'os = "macos"'
after: always
revision: 1
---

The first alerter run triggers the macOS notification permission prompt. Click Allow:

```sh
alerter --title "Setup" --message "Click Allow" --sound default --timeout 10
```
