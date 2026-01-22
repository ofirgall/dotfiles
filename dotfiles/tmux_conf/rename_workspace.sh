#!/usr/bin/env bash

set -e

CONFIG_LOC="$HOME/.config/hypr/UserConfigs/VirtualDesktopsNames.conf"

function rename_workspace() {
    local id=$1
    local name=$2

    local ws_names=$(cat $CONFIG_LOC | sed -n 's/^[[:space:]]*names[[:space:]]*=[[:space:]]*\([^#]*\).*/\1/p')

    ws_names=$(sed -E "s/(^|, )[[:space:]]*$id:[^,]*/\1$id:$name/" <<< "$ws_names")

    cat <<EOF > $CONFIG_LOC
plugin {
    virtual-desktops {
        names = $ws_names
    }
}
EOF

}

if [[ -n "$1" && "$1" == "empty" ]]; then
    current_workspace=$(hyprctl printdesk -j | jq -r '.virtualdesk.id')
    rename_workspace $current_workspace $current_workspace
    exit
fi

current_session=$(tmux display-message -p '#S')

if [[ "$current_session" == *"-viewer" ]]; then
    exit # Ignore viewer sessions
fi

current_workspace=$(hyprctl printdesk -j | jq -r '.virtualdesk.id')
icon=""
rename_workspace $current_workspace "$current_workspace $icon $current_session"
