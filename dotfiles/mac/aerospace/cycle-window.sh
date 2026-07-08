#!/bin/bash

if aerospace fullscreen off --fail-if-noop 2>/dev/null; then
    aerospace focus --wrap-around dfs-next
    aerospace fullscreen on
else
    aerospace focus --wrap-around dfs-next
fi
