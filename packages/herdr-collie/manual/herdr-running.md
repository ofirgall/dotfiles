---
id: herdr-running
title: Start herdr (Collie's setup and bridge need a running herdr server)
when: 'os = "macos"'
after: install
check: 'herdr status server 2>/dev/null | grep -q "^status: running"'
revision: 1
---

Collie runs as a herdr plugin, so its setup (`herdr-collie-setup`: push keys, start the bridge)
needs the herdr server up. Open a terminal and run `herdr` (it starts the server), then
`dots apply herdr-collie-setup`.
