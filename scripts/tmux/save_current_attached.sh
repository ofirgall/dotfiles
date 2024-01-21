#!/usr/bin/env sh

tmux list-clients -F '#S' > ~/.tmux/attached_clients
