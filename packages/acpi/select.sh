# select.sh check|install: link the acpi events of this machine's hardware tag, plus the actions.
set -eu
src="$DOTS_PKG_DIR/acpi"
case " ${DOTS_TAGS:-} " in
*" dell "*) hw=dell ;;
*" thinkpad "*) hw=thinkpad ;;
*) echo "acpi: needs the dell or thinkpad tag" >&2; exit 1 ;;
esac
pairs() { # print "<link> <target>" for every file
	for f in "$src/events_$hw"/*; do echo "/etc/acpi/events/$(basename "$f") $f"; done
	for f in "$src/actions"/*; do echo "/etc/acpi/actions/$(basename "$f") $f"; done
}
if [ "$1" = check ]; then
	pairs | while read -r link target; do
		[ "$(readlink "$link" 2>/dev/null)" = "$target" ] || exit 1
	done
else
	S=""; [ "$(id -u)" = 0 ] || S="sudo -n"
	$S mkdir -p /etc/acpi/events /etc/acpi/actions
	pairs | while read -r link target; do $S ln -sfv "$target" "$link"; done
	$S systemctl restart acpid.service || true
fi
