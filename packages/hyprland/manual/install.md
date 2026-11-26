---
id: install
title: Install Hyprland
when: 'all(os = "linux", gui)'
after: always
check: "command -v Hyprland"
revision: 1
---

dots does not install the compositor (the old installer never did either).
Install Hyprland from your distro or PPA so that `command -v Hyprland` succeeds.
Also install the `hyprland-plugin-deps` meta package from the same source: `hyprpm` needs it to
build the plugins (`hyprland-plugins` package).
