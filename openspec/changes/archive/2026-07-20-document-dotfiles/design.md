## Context

The dotfiles repo has no formal documentation of its capabilities. Knowledge of how things work lives in the config files themselves and in the maintainer's head. The repo targets macOS and Ubuntu with a layered architecture: shared configs in `common.conf.yaml`, platform-specific configs in `install.conf.yaml` (Linux) and `macos.conf.yaml` (macOS), and per-tool install scripts in `install_scripts/` and `install_scripts/mac/`.

## Goals / Non-Goals

**Goals:**
- Document every capability as a standalone spec file
- Capture cross-OS consistency patterns (especially the keybinding contract)
- Make the system understandable without reading every config file
- Establish the spec structure for future changes to build on

**Non-Goals:**
- No code or config changes
- Not designing a new bootstrap system (Dotbot replacement is future work)
- Not deep-diving into every tool's config options — specs describe what the tool does in this setup and how it's installed, not every setting
- Not documenting legacy capabilities in depth (AwesomeWM, Windows, Alacritty get brief mentions, not full specs)

## Decisions

### Spec granularity: one spec per capability domain

Each spec covers a logical capability (shell, terminal, tmux, etc.) rather than one spec per config file or one spec per tool. This keeps the count manageable (17) while still being specific enough to be useful.

Alternative considered: one spec per tool (ghostty.md, aerospace.md, karabiner.md...) — rejected because many tools exist to serve a single capability (e.g., Karabiner + xmodmap both serve "keyboard remapping") and the cross-OS story is the interesting part.

### Keybinding philosophy as a standalone spec

The keybinding contract spans window management, terminal, tmux, and editor. Rather than scattering binding tables across each tool's spec, there's a dedicated `keybinding-philosophy` spec that defines the canonical bindings and how each OS implements them. Individual tool specs reference it.

### Scripts spec uses a flat catalog with OS column

The scripts directory has ~50 scripts across 9 subdirectories. Rather than grouping by "universal vs platform-specific," the spec uses a flat table per subdirectory with an OS column (All / macOS / Ubuntu / Legacy). This matches how the directory is actually organized and avoids imposing a categorization that doesn't exist in the file structure.

### Spec files go under `openspec/specs/<name>/spec.md`

Following OpenSpec convention. Each capability gets its own directory, allowing future additions (e.g., test files, examples) without restructuring.

## Risks / Trade-offs

- **Specs may drift from reality** → Mitigated by keeping specs descriptive (what exists today) rather than prescriptive (what should exist). Future changes update specs via OpenSpec's delta spec workflow.
- **17 specs is a lot to write at once** → Accepted trade-off. Writing them together ensures consistency in style and cross-references. Tasks are ordered so the foundational specs (overview, bootstrap, keybinding-philosophy) come first.
- **Some submodules aren't checked out on macOS** (zsh-conf, hypr-dots) → Specs for those capabilities describe the contract and config structure based on what's visible in the repo (dotbot configs, install scripts) rather than the submodule contents.
