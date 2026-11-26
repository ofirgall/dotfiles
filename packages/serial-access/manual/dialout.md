---
id: dialout
title: Add your user to the dialout group (serial ports)
when: 'os = "linux"'
after: always
check: 'id -nG | grep -qw dialout'
requires: [logout]
revision: 1
---

```sh
sudo usermod -aG dialout "$USER"
```

Log out and back in for the group to apply. (The old installer ran `newgrp dialout`, which hangs
a non-interactive run, so it is dropped.)
