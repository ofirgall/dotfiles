#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
codex_config="${CODEX_HOME:-$HOME/.codex}/config.toml"

# Codex has no config include mechanism. Merge the portable footer settings
# rather than symlinking a whole config containing machine-specific state.
uv run --no-project --with tomlkit python - \
    "$repo_root/dotfiles/codex/statusline.toml" "$codex_config" <<'PY'
import os
import sys
from pathlib import Path

import tomlkit

source, target = map(Path, sys.argv[1:])
settings = tomlkit.parse(source.read_text())["tui"]
original = target.read_text() if target.exists() else ""
config = tomlkit.parse(original)
if "tui" not in config:
    config["tui"] = tomlkit.table()
for key, value in settings.items():
    config["tui"][key] = value
updated = tomlkit.dumps(config)
if updated != original:
    target.parent.mkdir(parents=True, exist_ok=True)
    if target.exists():
        backup = target.with_name("config.toml.before-statusline")
        if not backup.exists():
            backup.write_text(original)
            backup.chmod(0o600)
    fd = os.open(target, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
    with os.fdopen(fd, "w") as output:
        output.write(updated)
print(f"Codex statusline configured in {target}")
PY
