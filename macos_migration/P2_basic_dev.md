# P2: Basic Dev Setup

Goal: Ghostty terminal + Koala Vim + working shell environment.

## Items

### Homebrew bootstrap
- **Linux source**: N/A (apt-based)
- **macOS approach**: Install script that runs `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
- **Status**: [ ] Not started
- **Notes**: Foundation for everything else. Needs to be first step.

### Ghostty terminal
- **Linux source**: `dotfiles/ghostty/config`, `install_scripts/install_ghostty.sh` (builds from source on Linux)
- **macOS approach**: `brew install --cask ghostty` (native .app available)
- **Status**: [ ] Not started
- **Notes**: Config is mostly portable. Changes needed for macOS:
  - `window-decoration = none` → consider `server` for native title bar, or keep `none` for minimal look
  - Keybinds using `super+` work differently on macOS (super = Cmd). Review each keybind.
  - The `ctrl+tab`, `ctrl+shift+tab` passthrough binds should work as-is
  - Ghostty plugins (shaders) install identically: `git clone` to `~/.config/ghostty/shaders`

### Font: CaskaydiaCove Nerd Font
- **Linux source**: `install_scripts/install_fonts.sh`
- **macOS approach**: `brew install --cask font-caskaydia-cove-nerd-font`
- **Status**: [ ] Not started
- **Notes**: Required by both Ghostty and Neovim (statusline icons).

### Neovim (Koala Vim)
- **Linux source**: `dotfiles/.kvim.conf`, `install_scripts/install_nvim.sh`
- **macOS approach**: `brew install neovim`. Koala Vim config is platform-agnostic (JSON). Just symlink `~/.kvim.conf`.
- **Status**: [ ] Not started
- **Notes**: May need to install LSP servers (lua-language-server, pyright, etc.) via brew or mason.nvim handles it.

### Zsh + shell config
- **Linux source**: `install_scripts/install_zsh.sh`, `dotfiles/profile`
- **macOS approach**: Zsh is default on macOS. Port `.profile`/`.zshrc` contents. Likely need to adjust PATH setup for Homebrew (`/opt/homebrew/bin`).
- **Status**: [ ] Not started
- **Notes**: Some Linux-specific entries in profile (asdf shims, systemd paths) won't apply. Need a conditional or separate macOS profile.

### Tmux
- **Linux source**: `install_scripts/install_tmux.sh`, tmux config (separate repo/submodule?)
- **macOS approach**: `brew install tmux`. Config should be portable.
- **Status**: [ ] Not started
- **Notes**: tmux is central to the workflow (session management, agents-status integration, viewer scripts). Must work identically.

### Git config
- **Linux source**: `dotfiles/gitconfig`, `dotfiles/gitignore_global`
- **macOS approach**: Symlink both files. Fully portable.
- **Status**: [ ] Not started
- **Notes**: May want to add macOS-specific entries to gitignore_global (`.DS_Store`, etc.)

### Ripgrep config
- **Linux source**: `dotfiles/ripgreprc`
- **macOS approach**: `brew install ripgrep`, symlink config.
- **Status**: [ ] Not started
- **Notes**: Fully portable.

### Cursor CLI wrapper
- **Linux source**: `dotfiles/cursor-cli-wrapper.toml`
- **macOS approach**: Symlink to `~/.config/cursor-cli-wrapper/config.toml`. Portable.
- **Status**: [ ] Not started
- **Notes**: Hooks reference `~/dotfiles_scripts/agents-status/helpers.sh` which needs to exist.

## Install order

1. Homebrew
2. Font
3. Ghostty
4. Neovim + Koala Vim
5. Tmux
6. Zsh config
7. Git config + ripgrep
8. Cursor CLI wrapper

## Brew bundle approach

Consider a `Brewfile` in this directory:

```ruby
# Brewfile
cask "ghostty"
cask "font-caskaydia-cove-nerd-font"
brew "neovim"
brew "tmux"
brew "ripgrep"
brew "fd"
brew "fzf"
brew "git-delta"
brew "lazygit"
```

Install with `brew bundle --file=macos_migration/Brewfile`.
