# Tools Migration Status

Tools from Linux install scripts and their macOS status.

## Not yet installed — PORTABLE (can be added)

| Tool | Linux source | What it does | macOS install |
|------|-------------|--------------|---------------|
| ripgrep | `install_basic.sh` | Fast grep | `brew install ripgrep` |
| fd | `install_basic.sh` | Fast find | `brew install fd` |
| fzf | `install_basic.sh` | Fuzzy finder | `brew install fzf` |
| difftastic | `install_basic.sh` | Structural diff | `cargo install difftastic` |
| du-dust | `install_basic.sh` | Disk usage TUI | `cargo install du-dust` |
| git-delta | `install_basic.sh` | Git pager | `cargo install git-delta` |
| jless | `install_basic.sh` | JSON viewer TUI | `cargo install jless` |
| igrep | `install_basic.sh` | Interactive grep | `cargo install igrep` |
| bottom (btm) | `install_basic.sh` | System monitor TUI | `cargo install bottom --locked` |
| fx | `install_basic.sh` | JSON viewer | `brew install fx` |
| btop | `install_basic.sh` | System monitor | `brew install btop` |
| tuitab | `install_tuis.sh` | CSV/table TUI | `cargo install tuitab` |
| lemmy-help | `install_nvim.sh` | Neovim doc gen | `cargo install lemmy-help --features=cli` |
| ghostty-shaders | `install_ghostty_plugins.sh` | Cursor shaders | `git clone` to `~/.config/ghostty/shaders` |
| jq | `install_zsh.sh` | JSON processor | `brew install jq` |
| libtmux (python) | `install_tmux.sh` | tmux python lib | `pip install libtmux` |
| brotab | `install_basic.sh` | Browser tab manager |
