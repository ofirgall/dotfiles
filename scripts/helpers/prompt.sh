#!/usr/bin/env sh

yes_no() {
    while true; do
        printf "$1? [y/n] "
        read yn
        case $yn in
            [Yy]* ) return 0 ;;
            [Nn]* ) return 1 ;;
            * );;
        esac
    done
}
