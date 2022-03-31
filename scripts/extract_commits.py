#!/usr/bin/env python3

import os
import typer
import subprocess
import re
from pathlib import Path

HUNK_PATTERN = re.compile('@@ .+? @@.+?\n')
INDEX_PATTERN = re.compile('index [a-f0-9].+?..[a-f0-9].+? [0-9].+?\n')

def split_commit_line(line: bytes):
    line_parts = line.split(b' ')
    return line_parts[0], b' '.join(line_parts[1:])

def strip_patch(patch: str) -> str:
    patch = HUNK_PATTERN.sub('HUNK\n', patch)
    patch = INDEX_PATTERN.sub('index\n', patch)
    return patch

def extract_commits(start_commit: str, end_commit: str, out_dir: Path):
    typer.echo(f"Out dir: {out_dir}")
    commit_lines = subprocess.check_output([f'git log {start_commit}^..{end_commit} --format=oneline'], shell=True).splitlines()

    for commit, msg in [split_commit_line(line) for line in commit_lines]:
        patch = subprocess.check_output([f'git show {commit.decode()} --format= --unified=0'], shell=True).decode()
        with open(out_dir / msg.decode().replace('/', ''), 'w') as f:
            print(out_dir / msg.decode())
            f.write(strip_patch(patch))

def main(start_commit: str, end_commit: str, out_dir: Path):
    if out_dir is None:
        typer.echo("No out dir")
        raise typer.Abort()
    elif out_dir.is_dir():
        extract_commits(start_commit, end_commit, out_dir)
    elif not out_dir.exists():
        os.mkdir(out_dir)
        extract_commits(start_commit, end_commit, out_dir)
    else:
        typer.echo("out dir isnt a dir")
        raise typer.Abort()

if __name__ == '__main__':
    typer.run(main)
