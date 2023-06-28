#!/usr/bin/env python3

import typer
import json
from pathlib import Path

app = typer.Typer()


@app.command()
def add(path: Path, flag: str):
    with open(path, 'r') as file:
        commands = json.load(file)

    for command in commands:
        command['command'] = command['command'] + f' {flag}'

    with open(path, 'w') as file:
        json.dump(commands, file, indent=4)

@app.command()
def remove(path: Path, flag: str):
    with open(path, 'r') as file:
        commands = json.load(file)

    for command in commands:
        command['command'] = command['command'].replace(f' {flag}', '')

    with open(path, 'w') as file:
        json.dump(commands, file, indent=4)

if __name__ == '__main__':
    app()
