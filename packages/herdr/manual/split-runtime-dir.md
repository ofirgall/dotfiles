---
id: split-runtime-dir
title: Split herdr's runtime files out of the repo (~/.config/herdr must not be a symlink)
when: 'os = "macos"'
after: files
check: 'test ! -L ~/.config/herdr'
revision: 1
---

Before dots, `~/.config/herdr` was a symlink to `~/dotfiles/dotfiles/herdr`, so herdr wrote its
runtime state (plugins, sessions, sockets, logs) into the repo. dots manages single files inside
a real `~/.config/herdr` directory instead. Do this once, with herdr stopped:

```sh
herdr server stop 2>/dev/null; pkill -x herdr
old="$(cd -P ~/.config/herdr && pwd)"          # the repo copy that holds the runtime files
mkdir ~/.config/herdr.new
cd "$old"
mv plugins plugins.json .locks sessions session.json session-snapshots *.log *.sock* \
   ~/.config/herdr.new/ 2>/dev/null || true       # whichever of these exist
rm ~/.config/herdr                                 # the symlink
mv ~/.config/herdr.new ~/.config/herdr
dots apply herdr --files-only --yes                # links config.toml, scripts/, agent-detection/
```

Check: `herdr plugin list` still lists your plugins, and `git status` in the repo shows no
herdr runtime files.
