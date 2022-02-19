#!/bin/bash

IS_REMOTE=false
if test -f "$HOME/.remote_indicator"; then
  IS_REMOTE=true
fi

# TODO: utilize this if needed someday
IS_APT=false
if [ -n "$(command -v apt-get)" ]; then
	IS_APT=true
fi

NO_SUDO=false
if test -f "$HOME/.no_sudo_inidcator"; then
  NO_SUDO=true
fi
