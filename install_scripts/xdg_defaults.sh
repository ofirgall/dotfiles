#!/bin/bash -e

xdg-mime default gh-markdown-preview.desktop text/markdown

xdg-settings set default-web-browser hypr-browser.desktop
