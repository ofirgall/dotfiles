#!/usr/bin/env python3
# PYTHON_ARGCOMPLETE_OK
# PYZSHCOMPLETE_OK


# NOTE: sessions window title must have "tmux-go-session:{session}"

import pyzshcomplete
import argcomplete
import argparse
import libtmux
import subprocess

def yes_no_prompt(question: str) -> bool:
    answer = input(f'{question}? [Y/n] ')
    return answer.lower() != 'n'

def get_last_desktop() -> int:
    return int(subprocess.check_output(['wmctrl', '-d']).splitlines()[-1].split(b' ')[0])

def new_terminal_with_session(session: str, desktop_id: int):
    shell = subprocess.check_output(['echo $SHELL'], shell=True).decode().strip()
    subprocess.Popen(['/usr/bin/x-terminal-emulator', '-t', f'tmux-go-session:{session}', '-e', shell, '-c', f'export OPEN_TMUX_SESSION={session}; export OPEN_AT_DESK={desktop_id}; zsh -i'])

def new_workspace_prompt(session: str):
    print(f'{session} window not found\n')

    if not yes_no_prompt('Open new Workspace'):
        return

    new_terminal_with_session(session, get_last_desktop())


def go_to_workspace(session: str) -> bool:
    window_title = f'tmux-go-session:{session}'
    windows = subprocess.check_output(['wmctrl', '-l']).decode()

    if window_title not in windows:
        return False

    subprocess.check_call(['wmctrl', '-a', window_title])
    return True

def main():
    server = libtmux.Server()
    sessions = server.list_sessions()
    # import IPython
    # IPython.embed()

    parser = argparse.ArgumentParser('Go to Tmux Session')

    parser.add_argument('session', choices=[s['session_name'] for s in sessions])

    argcomplete.autocomplete(parser)
    pyzshcomplete.autocomplete(parser)

    args = parser.parse_args()

    if not go_to_workspace(args.session):
        new_workspace_prompt(args.session)

if __name__ == '__main__':
    main()
