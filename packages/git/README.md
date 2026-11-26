# git

`gitconfig` is the base (priority 0 fragment of `~/.gitconfig`); `delta` and `difftastic` add their own sections, and
`gitconfig.ssh-urls` (the `url.*.insteadOf` ssh rewrites) is skipped in the `sandbox` tag.

It uses `includeIf gitdir` to load `~/.git_work` for repos under `~/workspace/work/`, `~/workspace/kernels/`, and
`~/go/`. This switches git identity (email, name) and SSH key (`core.sshCommand`) per workspace: personal repos use
the default SSH key, work repos use the key configured in `~/.git_work` (untracked, see the repo README).
`gitignore_global` is the global ignore file configured through `.gitconfig`.
