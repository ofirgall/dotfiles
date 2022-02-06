#!/usr/bin/env python3
# PYTHON_ARGCOMPLETE_OK
# PYZSHCOMPLETE_OK


# NOTE: sessions window title must have "tmux-go-session:{session}"

import pyzshcomplete
import argcomplete
import argparse
import libtmux
import subprocess
import re
from os import path

LAST_JUMPED_SESSION_FILE = path.expandvars(path.join('$HOME', '.tmux_go_last'))
LAST_SESSION_KEYWORD = 'last'

class TmuxGoMultipleDesktops(Exception):
    def __init__(self, message):
        super().__init__(message)

class TmuxGoSessioNotFound(Exception):
    def __init__(self, message):
        super().__init__(message)

class TmuxGoActiveSessionNotFound(Exception):
    def __init__(self, message):
        super().__init__(message)

def get_last_session_name() -> str:
    with open(LAST_JUMPED_SESSION_FILE, 'r') as f:
        return f.read()

def yes_no_prompt(question: str) -> bool:
    answer = input(f'{question}? [Y/n] ')
    return answer.lower() != 'n'

def get_last_desktop() -> int:
    return int(subprocess.check_output(['wmctrl', '-d']).splitlines()[-1].split(b' ')[0])

def goto_desktop(desktop_id: int):
    subprocess.check_call(['wmctrl', '-s', str(desktop_id)])

def new_terminal_with_session(session: str, desktop_id: int, go_after_create: bool):
    shell = subprocess.check_output(['echo $SHELL'], shell=True).decode().strip()
    subprocess.Popen(['/usr/bin/x-terminal-emulator', '-t', f'tmux-go-session:{session}', '-e', shell, '-c', f'export OPEN_TMUX_SESSION={session}; export OPEN_AT_DESK={desktop_id}; zsh -i'])

    if go_after_create:
        goto_desktop(desktop_id)

def get_current_desktop() -> int:
    desktops = subprocess.check_output(['wmctrl', '-d']).splitlines()
    for desktop in desktops:
        desktop_parts = desktop.split()
        if desktop_parts[1] == b'*':
            return int(desktop_parts[0])
    raise Exception('Not active desktop found!')

def get_desktop_with_session(session: str) -> int:
    window_title = f'tmux-go-session:{session}'
    windows = subprocess.check_output(['wmctrl', '-l']).decode()

    if window_title not in windows:
        raise TmuxGoSessioNotFound('Active Session Window not Found')

    windows_with_title = [win for win in windows.splitlines() if window_title in win]
    if len(windows_with_title) != 1:
        raise TmuxGoMultipleDesktops('Found multiple windows with the same session title')

    desktop_id = windows_with_title[0].split()[1]
    return int(desktop_id)

def get_active_session_in_desktop(desktop_id: int) -> str:
    windows = subprocess.check_output(['wmctrl', '-l']).splitlines()

    for window in windows:
        parts = window.decode().split()
        desk = parts[1]
        window_title = ' '.join(parts[3:])
        if int(desk) == desktop_id:
            match = re.match(r'.*tmux-go-session:(.+?)($|\s)', window_title, re.DOTALL)
            if match is None:
                continue

            return match.group(1)

    raise TmuxGoActiveSessionNotFound('Active Session Not Found')

def go_to_workspace(session: str) -> bool:
    if session == LAST_SESSION_KEYWORD:
        session = get_last_session_name()

    try:
        current_session = get_active_session_in_desktop(get_current_desktop())
        if session == current_session: # Don't jump if target session is the active
            return True

        with open(LAST_JUMPED_SESSION_FILE, 'w') as f:
            f.write(current_session)
    except TmuxGoActiveSessionNotFound:
        pass

    subprocess.check_call(['wmctrl', '-s', str(get_desktop_with_session(session))])
    return True

def go_to_session(session: str):
    try:
        go_to_workspace(session)
    except TmuxGoSessioNotFound:
        new_terminal_with_session(session, get_last_desktop(), True)

def main():
    server = libtmux.Server()
    sessions = server.list_sessions()
    # import IPython
    # IPython.embed()

    parser = argparse.ArgumentParser('Go to Tmux Session')

    parser.add_argument('session', choices=[LAST_SESSION_KEYWORD] + [s['session_name'] for s in sessions])

    argcomplete.autocomplete(parser)
    pyzshcomplete.autocomplete(parser)

    args = parser.parse_args()

    go_to_session(args.session)

if __name__ == '__main__':
    main()
