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

### Install Fonts for Terminal Icons
* [Normal](https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/UbuntuMono/Regular/complete/Ubuntu%20Mono%20Nerd%20Font%20Complete%20Mono.ttf)


---

## Custom Mapping
Done by dconf (gnome tweaks):
* Capslock is mapped to Escape - Don't move your hands when escaping insert mode.
* Both shift changes language - Don't move your hands while typing.
* Right Alt is mapped to backspace - Same idea.. (done with ~/.xmodmap too)
* Changing workspaces - Ctrl+J/H, Ctrl+Shift+J/H

---

## TODO
* nvim - conflicts doesn't show what actually changed, simulate and open issue in vim-fugitive?
* rsync git dirty files/rsync on write in nvim
* nvim - add gxd and more
* tmux - if getting into copy mode in nested session suspend automaticly
* nvim - gvd (max 2 splits, if split exist override it)
* nvim - nvim-tree chmod
* nvim - solve conflict doesn't show what added and what was exist
* zsh - zinit
* nvim - fast boot time for single files (don't load few plugins)
* nvim + zshrc - set $VIEWER to faster nvim config and $EDITOR to heavier one
* tmux - better window names (maybe write a plugin for that)
* tmux - make last_command faster
* nvim - resize panes like tmux
* nvim - learn to use marks
* firenvim - paste
* Shift/Ctrl R_Alt -> Delete
* tmux - not suspended (not active) change status colors 
* nvim - fix neogen next/prev (collides with snippy (tab/s-tab))
* dock-redock fix
* increase osc52 yank amount (when alacritty will support that)
* git squash - if master/base branch moved forward can't find the ref
* nvim - stop lsp server on background
* nvim - build & run + quickfix errors
* nvim - try distant one day
* tuis to try - slack, mail, calander, jira
* autoupdate dotfiles on remote machines
* oh-my-tmux to upstream instead of local copy

## TODO Takes time
* create/attach - to the same session when connecting to remote (not sure if possible)
* taskwarrior - filter presets
* tmux-go + taskwariror - Annotate tmux session and go with tmux-go 
* tmux-browser
* tmux-go
* tmux-remote-notify
* when opening link ask to which session (can be in taskopen shortcut for now and later inside tmux-browser (maybe a webbrowser wrapper))
* backup non-dotfiles - tmux sessions, tasks of taskwarrior, nvim sessions
* backup firefox extnesions & settings
* tmux - better session workflow, session per feature:repo, fzf for features -> fzf for repo
* convert todos to tasks/issues


## Improvements Ideas
* nvim? - signature renaming using tree sitter and LSP
