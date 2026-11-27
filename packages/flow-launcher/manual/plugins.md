---
id: plugins
title: Install the Flow Launcher plugins (Clipboard+, Window Walker)
when: 'os = "windows"'
after: install
check: 'if ((Get-ChildItem "$env:APPDATA\FlowLauncher\Plugins" -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "Clipboard\+|Window ?Walker" }).Count -ge 2) { exit 0 } else { exit 1 }'
revision: 1
---

Open Flow Launcher (`Alt+Space`) and run:

```
pm install Clipboard+
pm install Window Walker
```

The plugin manager is part of the app and has no CLI, so dots cannot do this. The check looks for both
folders under `%APPDATA%\FlowLauncher\Plugins`.
