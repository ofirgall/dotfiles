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


def go_to_workspace(session: str) -> bool:
    window_title = f'tmux-go-session:{session}'
    windows = subprocess.check_output(['wmctrl', '-l']).decode()

    if window_title not in windows:
        return False

    windows_with_title = [win for win in windows.splitlines() if window_title in win]
    if len(windows_with_title) != 1:
        print('Found multiple windows with the same session title')
        return False

    desktop_id = windows_with_title[0].split()[1]
    subprocess.check_call(['wmctrl', '-s', desktop_id])
    return True

def go_to_session(session: str):
    if not go_to_workspace(session):
        new_terminal_with_session(session, get_last_desktop())

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

    go_to_session(args.session)

if __name__ == '__main__':
    main()
