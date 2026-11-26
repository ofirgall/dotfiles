#!/usr/bin/env sh

yes_no() {
	while true; do
		printf "$1? [y/n] "
		read yn
		case $yn in
		[Yy]*) return 0 ;;
		[Nn]*) return 1 ;;
		*) ;;
		esac
	done
}

yes_no_default_yes() {
	while true; do
		printf "$1? [Y/n] "
		read yn
		case $yn in
		[Yy]*) return 0 ;;
		[Nn]*) return 1 ;;
		"") return 0 ;;
		*) ;;
		esac
	done
}

yes_no_default_no() {
	while true; do
		printf "$1? [Y/n] "
		read yn
		case $yn in
		[Yy]*) return 0 ;;
		[Nn]*) return 1 ;;
		"") return 1 ;;
		*) ;;
		esac
	done
}
