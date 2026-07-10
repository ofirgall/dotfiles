# Dotfiles
The files here are linked to `$HOME` (`~`). Check `*.conf.yaml` in the root dir for more details

* `zsh_conf` - the zsh config
* `tmux_conf` - the tmux config
* `gitconfig` - my `.gitconfig`. Uses `includeIf gitdir` to load `~/.git_work` for repos under `~/workspace/work/`, `~/workspace/kernels/`, and `~/go/`. This switches git identity (email, name) and SSH key (`core.sshCommand`) per workspace -- personal repos use the default SSH key, work repos use the key configured in `~/.git_work`.
* `gitignore_global` - gitignore for all my repos, configured through `.gitconfig`
* `alacritty.yml` - config for my terminal, [alacritty](https://github.com/alacritty/alacritty)
* `fusuma.yml` - config for touchpad gestures, [fusuma](https://github.com/iberianpig/fusuma)
* `profile` - my `~/.profile`
* `taskrc` - config for my task manager, [taskwarrior](https://github.com/GothenburgBitFactory/taskwarrior) which I use with [taskwarrior-tui](https://github.com/kdheepak/taskwarrior-tui)
* `vimrc` - basic `~/.vimrc`
* `xmodmaprc` - Configures custom keymaps
