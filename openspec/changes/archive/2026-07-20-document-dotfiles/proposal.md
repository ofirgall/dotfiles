## Why

The dotfiles repo has grown organically to support macOS and Ubuntu with a "Linux-first muscle memory on every OS" philosophy, but none of this is formally documented. There's no single source of truth describing what capabilities exist, how they map across OSes, or what the keybinding contract is. Spec files will make the system understandable, maintainable, and reproducible — especially when setting up a new machine or onboarding to a new OS.

## What Changes

- Create 17 spec files documenting every capability in the dotfiles system
- No code changes — this is pure documentation of existing state
- Specs cover: philosophy, bootstrap process, shell/terminal/editor configs, window management, keybinding translation, input devices, dev tools, scripts catalog, and custom tooling

## Capabilities

### New Capabilities

- `overview`: Dotfiles philosophy, multi-OS portability goal, target platforms (macOS + Ubuntu), the "Linux-first" interaction model
- `bootstrap`: Install entrypoints (./install, ./install-macos), Dotbot config layering (common → platform), submodules, remote/no-sudo indicator files
- `shell`: zsh-conf (submodule), my-zsh-conf customizations, starship prompt, profile, env
- `terminal`: Ghostty (primary), platform shim pattern (config.platform symlink), Alacritty (legacy Linux)
- `editor`: KoalaVim/nvim (submodule), kvim.conf, vscode-settings (submodule), Cursor
- `tmux`: Config structure (entrypoint → settings/design/plugins/binds/hooks), nvim-aware binds, nested session support, TPM
- `git`: gitconfig, gitignore_global, delta, difftastic, gh-dash, git-utils install scripts
- `tui-tools`: CLI power tools summary — yazi, fzf, ripgrep, fd, bat, btop/bottom, broot, jless, igrep, du-dust, fx; different install paths per OS
- `window-management`: Hyprland (Ubuntu) + AeroSpace (macOS), grouped workspaces across monitors, AwesomeWM (legacy)
- `keybinding-philosophy`: Canonical binding table, Karabiner Ctrl→Cmd translation, terminal exclusions, Cmd→F-key bypass for AeroSpace, tmux/nvim Alt layer
- `status-bar`: SketchyBar (macOS), Waybar (Ubuntu/Hyprland), workspace indicators, agents-status integration
- `pointing-devices`: LinearMouse (macOS trackpad/mouse), libinput (Ubuntu), acceleration, scroll, drag behavior
- `keyboard-remapping`: Karabiner (macOS), xmodmap (Ubuntu), CapsLock→Esc, Fn↔Ctrl, Cmd↔Option on built-in keyboard — the "PC layout on Mac hardware" approach
- `dev-languages`: Go, Rust/Cargo, Node/Bun/npm, Python/uv — same toolchain goal, different install paths per OS
- `ai-tools`: Claude settings.json, cursor-cli-wrapper config, agents-status (KoalaVim org tool)
- `workspace-management`: ez-workspaces session/project picker, tmux integration, git-worktree plugin, per-OS config
- `scripts`: Full catalog of ~/dotfiles_scripts with OS compatibility column — git extensions, tmux management, notification abstraction, deploy shortcuts, inner scripts, helpers

### Modified Capabilities

(none — no existing specs)

## Impact

- No code changes
- Adds 17 spec files under `openspec/specs/`
- Establishes the spec structure for all future dotfiles changes
