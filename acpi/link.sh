#!/usr/bin/env bash

if [ "$#" -lt 1 ]; then
    echo 'Usage: ./link <hardware (dell)>'
	exit 1
fi

hardware=$1

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $CURRENT_DIR

if ! test -d "events_$hardware"; then
    echo "events_$hardware dir doesn't exists"
    exit 1
fi


echo "Linking events of events_$hardware to /etc/acpi/events/"
for f in $(ls "events_$hardware"); do
    sudo ln -s -v "$CURRENT_DIR/events_$hardware/$f" "/etc/acpi/events/$f"
done

echo "Linking actions to /etc/acpi/actions/"
for f in $(ls "actions"); do
    sudo ln -s -v "$CURRENT_DIR/actions/$f" "/etc/acpi/actions/$f"
done
