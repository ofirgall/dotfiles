# zsh

Installs zsh and wires the two config submodule-style dirs:

- `zsh-conf/` (submodule, `~/.zsh-conf`) and `my-zsh-conf/` (`~/.my-zsh-conf`) are dir links.
- `~/.zshenv` and `~/.zshrc` are real files; dots maintains one marked block in each
  (`zshenv.inject`, `zshrc.inject`). The other block in `~/.zshenv` is dots' own env block
  (PATH from packages). Don't symlink these files: dots writes through symlinks.
- `wslrc` is not linked anywhere (it never was on the dotbot setup either).
  TODO(dots-migration): decide whether `wslrc` should be sourced under WSL.

## Known leftovers

- TODO(dots-migration): `zsh-conf` and `my-zsh-conf` still test the old marker files
`~/.remote_indicator` and `~/.no_sudo_indicator` at runtime. On a remote box create the
marker by hand until zsh-conf reads the dots tags (needs dots to export tags to the shell
env, see MIGRATION.md section 9).

- TODO(dots-migration): zsh-conf generates `~/.config/starship.toml` itself; let dots render it.

- TODO(dots-migration): `my-zsh-conf/env.zsh` sources `~/secrets.zsh` (guarded, untracked);
`~/.git_work` (git includeIf) is untracked too. Both stay local.
