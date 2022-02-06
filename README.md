# Ofir's DotFiles

## Install
### Enable pre-commit hook for saving stuff (like dconf)
```bash
ln -s ../../pre-commit .git/hooks/pre-commit
```

### Set Git User
Set your `global` git user at ~/.git_user
```
[user]
	name = "Your Name"
	email = "yourname@gmail.com"
```

### Set Local Repo (for me)
Set `this repo` git user
```
git config user.email "your mail"
git config user.user "Ofir Gal"
```

### Clone and Run for Remote
```bash
git clone https://github.com/ofirgall/dotfiles.git && cd dotfiles && sudo echo a && ./install --config-file remote.conf.yaml && touch ~/.remote_indicator
```

### Clone and Run for PC
```bash
git clone https://github.com/ofirgall/dotfiles.git && cd dotfiles && sudo echo a && ./install
```

Incase you are using windows terminal add `windows_terminal_binds.json` to your windows terminal

### Install Fonts for Terminal Icons
* [Normal](https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/UbuntuMono/Regular/complete/Ubuntu%20Mono%20Nerd%20Font%20Complete%20Mono.ttf)


---

## Custom Mapping
Done by dconf (gnome tweaks):
* Capslock is mapped to Escape - Don't move your hands when escaping insert mode.
* Both shift changes language - Don't move your hands while typing.
* Right Alt is mapped to backspace - Same idea.. (done with ~/.xmodmap too)

---

## TODO Takes time
* create/attach - to the same session when connecting to remote
* taskwarrior - filter presets
* tmux-go - different repo
* tmux-go - close workspace
* tmux-go - add workspace
* tmux-go + taskwariror - Annotate tmux session and go with tmux-go 
* tmux - is_vim not detected when using vim on remote inside other tmux not suspended
* tmux-browser
* when opening link ask to which session (can be in taskopen shortcut for now and later inside tmux-browser (maybe a webbrowser wrapper))
* tmux-remote-notify
* nvim - search filter history?
* backup non-dotfiles - tmux sessions, tasks of taskwarrior, nvim sessions
* backup firefox extnesions & settings
* tmux - go over binds, maybe want to change them.
* use bugwarrior (api for OKTA?)
* tmux-go - when openning a window attach it to a default workspace, e.g: slack -> main
* tmux-go? - open windows when attaching to session (main opens slack for example)
* tmux - better session workflow, session per feature:repo, fzf for features -> fzf for repo
* nvim - monakai colors are too bright (expect background), need to adjust it.
* nvim - diffview, lines filter
* nvim - diffview, filehistory for multiple commits merge_commit^..merge_commit (linux-kernel git hist 938edb8a31b976c9a92eb0cd4ff481e93f76c1f1^..938edb8a31b976c9a92eb0cd4ff481e93f76c1f1)

## TODO Major
* faster boot time for zsh
* nvim - learn to use marks
* taskwarrior - colors
* firenvim - paste
* Shift/Ctrl R_Alt -> Delete
* nvim - gd/gD etc. wrap text with "", added the file type automaticlly
* nvim - gD/gd/gi binds with splits
* nvim - fix neogen next/prev (collides with snippy (tab/s-tab))
* tmux - restart ssh connection
* tmux - not suspended (not active) change status colors 
* zsh - zsh-mode-vi makes issues with up/down partial history match
* tmux-reserruct - fix last bug

## TODO
* dock-redock fix
* git squash - if master/base branch moved forward can't find the ref
* tmux - go to start of last command, copy command output
* tmux - ssh connection when asked (prefix + o/e)
* nvim - stop lsp server on background
* nvim - build & run + quickfix errors
* nvim - try distant one day
* tuis to try - slack, mail, calander, jira
* autoupdate dotfiles on remote machines
* better readme, readme on keymaps in nvim, split repos

## Improvements Ideas
* nvim? - signature renaming using tree sitter and LSP
