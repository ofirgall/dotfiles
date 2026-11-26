---
id: input-group
title: Add your user to the input group
when: 'all(os = "linux", gui)'
after: always
check: 'id -nG | grep -qw input'
requires: [logout]
revision: 1
---

```sh
sudo usermod -a -G input $USER
```

Log out and in again (the old installer ran `newgrp input`, which dots can't do).
