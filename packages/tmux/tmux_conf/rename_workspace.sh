#!/usr/bin/env bash

# OLD SCRIPT TO rename_workspace by tmux events

# rename workspace in hyprland
# set-hook -g 'client-focus-in[1212]' "run-shell '$HOME/.tmux_conf/rename_workspace.sh'"
# set-hook -g 'client-attached[1212]' "run-shell '$HOME/.tmux_conf/rename_workspace.sh'"
# set-hook -g 'client-detached[1212]' "run-shell '$HOME/.tmux_conf/rename_workspace.sh empty'"

set -e

CONFIG_LOC="$HOME/.config/hypr/UserConfigs/VirtualDesktopsNames.conf"

function rename_workspace() {
    local id=$1
    local name=$2

    local ws_names=$(cat $CONFIG_LOC | sed -n 's/^[[:space:]]*names[[:space:]]*=[[:space:]]*\([^#]*\).*/\1/p')

    new_ws_names=$(sed -E "s/(^|, )[[:space:]]*$id:[^,]*/\1$id:$name/" <<< "$ws_names")

    if [ ! "$new_ws_names" = "$ws_names" ]; then
        cat <<EOF > $CONFIG_LOC
plugin {
    virtual-desktops {
        names = $new_ws_names
    }
}
EOF
    fi
}

if [[ -z "$TMUX" || ( -n "$1" && "$1" == "empty" ) ]]; then
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

# Trim projname-chore- prefix e.g drift-chore-DR-XXX..
set +e
jira_workspace_name=$(echo "$current_session" | grep -o '[A-Z]\+-[0-9].*')
workspace_name=${jira_workspace_name:-$current_session}
rename_workspace $current_workspace "$current_workspace $icon $workspace_name"
