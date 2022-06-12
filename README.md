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

### Clone and Run
#### Config
* `touch ~/.remote_indicator` - if remote
* `touch ~/.no_sudo_indicator` - if no sudo on machine
```bash
git clone https://github.com/ofirgall/dotfiles.git && cd dotfiles && ./install
```

Incase you are using windows terminal add `windows_terminal_binds.json` to your windows terminal

### Install TamperMonkey scripts
* Install [TamperMonkey](https://www.tampermonkey.net/)
* View the the [tampermonkey scripts](tampermonkey) as raw

---

## Custom Mapping
Done by dconf (gnome tweaks):
* Capslock is mapped to Escape - Don't move your hands when escaping insert mode.
* Both shift changes language - Don't move your hands while typing.
* Right Alt is mapped to backspace - Same idea.. (done with ~/.xmodmap too)
* Changing workspaces - Ctrl+J/H, Ctrl+Shift+J/H
* [tmux-go](https://github.com/ofirgall/tmux-go) shortcuts, Alt+G, Super+J/K/L/M

---

## TODO
* nvim - fugitive jump binds when filetype is git
* nvim - title generator
* nvim - close inactive `man` buffers
* nvim - git-messanger support multiple lines (maybe like gh)
* tmux - Neo-Oli/tmux-text-macros integrate tmux fzf menu
* tmux - Neo-Oli/tmux-text-macros better syntax for custom-macros
* nvim - diffconflicts isn't perfect yet (need to test with multiple conflicts in file + merges that solved)
* nvim - autosuspend Lsp/nvim if not active
* nvim - on save session ignore more file like flog diffview fugitive and such
* nvim - learn to use marks
* zellij
* firenvim - paste
* nvim - fix neogen next/prev (collides with snippy (tab/s-tab))
* increase osc52 yank amount (when alacritty will support that)
* git squash - if master/base branch moved forward can't find the ref
* nvim - build & run + quickfix errors
* nvim - try distant one day
* tuis to try - slack, mail, calander, jira
* autoupdate dotfiles on remote machines

## TODO Takes time
* tmux-go
* when opening link ask to which session (can be in taskopen shortcut for now and later inside tmux-browser (maybe a webbrowser wrapper))
* backup non-dotfiles - tmux sessions, tasks of taskwarrior, nvim sessions
* backup firefox extnesions & settings
* tmux - better session workflow, session per feature:repo, fzf for features -> fzf for repo
* convert todos to tasks/issues


## Improvements Ideas
* nvim? - signature renaming using tree sitter and LSP
