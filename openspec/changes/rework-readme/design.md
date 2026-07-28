## Context

The current README.md dates back to when the setup was Linux-only with AwesomeWM, alacritty, and Firefox. The repo now supports macOS (AeroSpace, SketchyBar, Ghostty, Karabiner), Windows (Komorebi, WezTerm, Kanata), and Linux (Hyprland). It uses Dotbot for orchestration, git submodules for external components, and a Makefile for submodule management. The README has stale TODOs, references to removed tools, and no mention of the current platform matrix or repo structure.

## Goals / Non-Goals

**Goals:**
- Provide a quick overview of what this dotfiles repo manages and which platforms it supports
- Show the repo directory structure so users can find configs
- Document install instructions per platform (macOS, Linux, Windows)
- Document submodule management via Makefile
- Keep the README concise and maintainable — detail lives in specs and platform-specific READMEs

**Non-Goals:**
- Exhaustive documentation of every config file (that's what openspec/specs/ is for)
- Screenshots/media of every tool (keep 1-2 representative visuals at most)
- Replacing platform-specific docs (macREADME/, etc.)

## Decisions

### Single flat README vs per-platform READMEs
**Decision:** Single README.md with platform sections. Per-platform READMEs already exist (macREADME/) for detailed post-install steps; the main README links to them.
**Rationale:** A single entry point is easier to maintain and discover. Deep platform details stay in their dedicated docs.

### Section order
**Decision:** Overview → Platform support → Repo structure → Install → Submodule management → Git setup
**Rationale:** Most readers want to understand what the repo does before how to install it. Repo structure helps orient before diving into install steps.

### Remove stale content
**Decision:** Drop all TODO lists, Firefox extension docs, AwesomeWM keymapping docs, and taskwarrior references entirely.
**Rationale:** These reference tools no longer in use. TODOs belong in issues or openspec changes, not README.

### Media
**Decision:** Keep media section minimal — reference existing screenshots only if they're current. Don't block on creating new screenshots.
**Rationale:** Screenshots go stale quickly. A text description of the workflow is more maintainable.

## Risks / Trade-offs

- [README drifts again] → Mitigated by keeping it high-level; detail lives in openspec specs which are maintained separately
- [Missing platform coverage] → The README lists platforms but links to per-platform docs for depth, so omissions in README are less critical
