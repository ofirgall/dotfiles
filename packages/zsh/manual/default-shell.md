---
id: default-shell
title: Make zsh your login shell
when: 'any(os = "linux", os = "macos")'
after: always
check: 'case "$(uname -s)" in Darwin) dscl . -read ~ UserShell | grep -q zsh ;; *) getent passwd "$USER" | grep -q zsh ;; esac'
revision: 1
---

```sh
chsh -s "$(command -v zsh)"
```

Log out and back in. On macOS `/bin/zsh` is already the login shell.
(The old installer ran `sudo chsh`; dots does not change accounts.)
