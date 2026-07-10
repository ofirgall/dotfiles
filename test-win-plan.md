# Windows Dotfiles Test Plan

## winghostty (Terminal)
- [ ] Launches from desktop shortcut
- [ ] Launches from Win+Enter
- [ ] Config loaded (font: CaskaydiaCove NFM, no window decoration, black bg)
- [ ] Zsh launches with correct prompt
- [ ] Keybinds work (Ctrl+Tab, Ctrl+Shift+Enter fullscreen toggle)
- [ ] Custom cursor shaders directory exists

## Komorebi + WHKD (Tiling WM)
- [ ] Starts from desktop shortcut (Restart Komorebi)
- [ ] Stops from desktop shortcut (Stop Komorebi)
- [ ] Win+Enter opens winghostty
- [ ] Win+b opens browser
- [ ] Win+h/j/k/l focus direction
- [ ] Win+Shift+h/j/k/l move window
- [ ] Win+1-9 switch workspace
- [ ] Win+Shift+1-9 move window to workspace
- [ ] Win+q close window
- [ ] Win+f monocle toggle
- [ ] Win+Shift+f float toggle
- [ ] Win+/ cycle layout
- [ ] Win+Ctrl+h/l resize
- [ ] Win+o cycle monitor (if multi-monitor)
- [ ] Win+,/. prev/next workspace
- [ ] Win+` last workspace
- [ ] Win+Ctrl+Shift+r reload config
- [ ] Win+Shift+; retile
- [ ] Float rules work (Task Manager, 1Password float)
- [ ] Manage rules work (Ghostty, Chrome tiled)

## YASB (Status Bar)
- [ ] Launches from desktop shortcut
- [ ] Stops from desktop shortcut
- [ ] Bar appears at top, 33px height
- [ ] Background color #151520
- [ ] Workspace indicators show 1-9
- [ ] Active workspace highlighted (#cba6f7)
- [ ] Clock widget (yellow #f9e2af)
- [ ] Battery widget (green #a6e3a1)
- [ ] Volume widget (sapphire #74c7ec)
- [ ] WiFi widget (teal #94e2d5)
- [ ] CPU widget (green #a6e3a1)
- [ ] RAM widget (sky #89dceb)
- [ ] Font: CaskaydiaCove NFM

## Kanata (Keyboard Remapper)
- [ ] Starts from desktop shortcut
- [ ] Stops from desktop shortcut
- [ ] CapsLock sends Escape

## CLI Tools (in winghostty/MSYS2)
- [ ] zsh works with correct config
- [ ] tmux starts, TPM loads plugins
- [ ] nvim / kv launches KoalaVim
- [ ] bat, rg, fd, fzf work
- [ ] git, delta (git diff pager)
- [ ] dust (du replacement)
- [ ] bottom (btm - system monitor)
- [ ] jq, yj work
- [ ] difftastic (difft)
- [ ] gh CLI + extensions (gh dash)

## Symlinks
- [ ] ~/.zshrc → dotfiles/zsh-conf/entrypoint.zsh
- [ ] ~/.config/nvim → editors/KoalaConfig
- [ ] ~/.tmux.conf → dotfiles/tmux_conf/entrypoint.tmux
- [ ] ~/.gitconfig → dotfiles/gitconfig
- [ ] ~/.config/ghostty → dotfiles/ghostty
- [ ] ~/AppData/Local/winghostty/config.ghostty → dotfiles/ghostty/config
- [ ] ~/.config/whkdrc → dotfiles/windows/komorebi/whkdrc
- [ ] ~/.config/komorebi/komorebi.json
- [ ] ~/.config/kanata/kanata.kbd
- [ ] ~/.config/yasb/config.yaml + styles.css
- [ ] ~/.config/yazi (file manager)

## System Settings
- [ ] KeyboardDelay=0, KeyboardSpeed=31
- [ ] SnapAssist disabled
- [ ] Developer Mode enabled
- [ ] All symlinks are real NTFS symlinks (not copies)

## Fonts
- [ ] CaskaydiaCove NFM installed
- [ ] JetBrainsMono NFM installed
- [ ] UbuntuMono NFM installed
- [ ] 0xProto NFM installed
- [ ] Italic variants of CaskaydiaCove removed

## Other
- [ ] `open` alias works (runs `start`)
- [ ] `toclip` works (clipboard)
- [ ] ez-workspaces (`ez`, `del`, `new`, `t`)
- [ ] agents-status installed
