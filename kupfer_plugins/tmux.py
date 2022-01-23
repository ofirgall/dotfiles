__kupfer_name__ = _('TmuxSessions')
__version__ = '0.1.0'
__author__ = 'Ofir'
__description__ = '''TmuxSessions Actions'''
__kupfer_sources__ = ("TmuxSessionSource",)
__kupfer_actions__ = ('OpenTmuxSession',)

from kupfer.objects import TextLeaf, Source, Action, Leaf
import libtmux

import sys
import os
sys.path.append(os.path.expandvars('$HOME/dotfiles_scripts/'))
from tmux_go import go_to_session, get_last_session_name, LAST_SESSION_KEYWORD

class OpenTmuxSession(Action):
    def activate(self, obj):
        session = obj.session
        go_to_session(session)

    def valid_for_item(self, leaf):
        return bool(leaf)

    def item_types(self):
        yield TmuxSessionLeaf


class TmuxSessionLeaf(Leaf):
    def __init__(self, session):
        session_display = session + ' tmux session'
        self.desc = f'{get_last_session_name()} (last)' if LAST_SESSION_KEYWORD == session else session

        super(self.__class__, self).__init__(session, _(session_display))
        self.session = session

    def get_description(self):
        return "TMUX SESSION: " + self.desc


class TmuxSessionSource(Source):
    def __init__(self):
        Source.source_user_reloadable = True
        Source.source_use_cache = False
        Source.__init__(self, _("Tmux Sessions"))

    def get_items(self):
        try:
            yield TmuxSessionLeaf('last')
        except FileNotFoundError:
            pass

        server = libtmux.Server()
        for session in server.list_sessions():
            yield TmuxSessionLeaf(session['session_name'])

    def provides(self):
        yield TmuxSessionLeaf

    def get_icon_name(self):
        return "gtk-directory"
