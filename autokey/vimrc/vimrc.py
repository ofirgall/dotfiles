import os
with open(os.path.expandvars('$HOME/.vimrc')) as f:
    vimrc = ' | '.join([l.strip() for l in f.readlines()])

clipboard.fill_selection(vimrc)

keyboard.press_key('<shift>')
keyboard.press_key('<insert>')
keyboard.release_key('<insert>')
keyboard.release_key('<shift>')

