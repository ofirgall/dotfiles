#!/bin/bash
# Record agent status changes with the detection evidence behind each one.
#
# herdr keeps no history of which rule fired. This subscribes to
# pane.agent_status_changed and, on every change, snapshots
# `herdr agent explain --json` plus the detection text the rules saw.
#
# Usage: record-agent-detection.sh [-o DIR] [PANE_ID...]
#   no PANE_ID  record every pane, including panes and agents started later
#   -o DIR      output dir (default: /tmp/herdr-detect-log/<timestamp>)
#
# Output:
#   events.jsonl                      one line per change: ts, pane, status, rule, fallback
#   <ts>-<seq>-<pane>-<status>.json   full explain output
#   <ts>-<seq>-<pane>-<status>.txt    detection text; replay with
#                                     herdr agent explain --file <txt> --agent <agent>
#
# status is what herdr shows; screen is what the manifest rules decided. They
# differ when a hook (herdr pane report-agent) owns the state, and "done" is
# just screen=idle on a pane you haven't focused since.
#
# The snapshot is taken right after the event arrives, so a screen that
# changes within milliseconds may already differ from what triggered it.

set -euo pipefail

OUT_DIR=""
while getopts "o:h" opt; do
	case "$opt" in
	o) OUT_DIR="$OPTARG" ;;
	h)
		sed -n '2,24p' "$0" | sed 's/^# \{0,1\}//'
		exit 0
		;;
	*) exit 1 ;;
	esac
done
shift $((OPTIND - 1))
FIXED_PANES=("$@")

SOCK="${HERDR_SOCKET_PATH:-$HOME/.config/herdr/herdr.sock}"
OUT_DIR="${OUT_DIR:-/tmp/herdr-detect-log/$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$OUT_DIR"
LOG="$OUT_DIR/events.jsonl"

all_panes() {
	herdr pane list | jq -r '.result.panes[].pane_id'
}

subscribe_request() {
	jq -cn --args '{
		id: "record-agent-detection",
		method: "events.subscribe",
		params: {subscriptions: (
			[$ARGS.positional[] | {type: "pane.agent_status_changed", pane_id: .}]
			+ [{type: "pane.agent_detected"}, {type: "pane.created"}]
		)}
	}' "$@"
}

record() {
	local pane="$1" status="$2" agent="$3"
	local ts base explain
	# macOS date has no sub-second field; the sequence keeps files unique.
	SEQ=$((SEQ + 1))
	ts=$(date +%Y%m%d-%H%M%S)
	base="$OUT_DIR/$ts-$(printf %04d "$SEQ")-${pane//:/_}-$status"

	herdr pane read "$pane" --source detection >"$base.txt" 2>/dev/null || true
	explain=$(herdr agent explain "$pane" --json 2>/dev/null || echo '{}')
	echo "$explain" >"$base.json"

	echo "$explain" | jq -c --arg ts "$ts" --arg pane "$pane" --arg status "$status" \
		--arg agent "$agent" --arg capture "$base.txt" '{
			ts: $ts, pane: $pane, status: $status, agent: (.agent // $agent),
			detected_state: .state, rule: .matched_rule,
			fallback: .fallback_reason, skipped: .skipped_update_reason,
			capture: $capture
		}' | tee -a "$LOG" |
		jq -r '"\(.ts)  \(.pane)  \(.agent // "?")  → \(.status)  screen=\(.detected_state // "-")  rule=\(.rule // "-")  fallback=\(.fallback // "-")"'
}
SEQ=0

echo "recording to $OUT_DIR (ctrl+c to stop)" >&2

FIFO_IN="$OUT_DIR/.sub-in"
FIFO_OUT="$OUT_DIR/.sub-out"
NC_PID=""
cleanup() {
	[[ -n "$NC_PID" ]] && kill "$NC_PID" 2>/dev/null
	rm -f "$FIFO_IN" "$FIFO_OUT"
}
trap 'cleanup; exit 0' INT TERM
trap cleanup EXIT

while true; do
	if ((${#FIXED_PANES[@]})); then
		panes=("${FIXED_PANES[@]}")
	else
		# Subscribe to every pane, so an agent starting in an existing pane is
		# covered; only brand-new panes need a resubscribe.
		panes=($(all_panes))
	fi
	echo "watching ${#panes[@]} pane(s): ${panes[*]}" >&2

	rm -f "$FIFO_IN" "$FIFO_OUT"
	mkfifo "$FIFO_IN" "$FIFO_OUT"
	# Hold the request side open so nc keeps the subscription alive.
	exec 3<>"$FIFO_IN"
	nc -U "$SOCK" <&3 >"$FIFO_OUT" &
	NC_PID=$!
	subscribe_request ${panes[@]+"${panes[@]}"} >&3

	while IFS= read -r line; do
		kind=$(jq -r '.event // empty' <<<"$line")
		case "$kind" in
		pane.agent_status_changed | pane_agent_status_changed)
			read -r pane status agent < <(jq -r '.data | "\(.pane_id) \(.agent_status) \(.agent // "")"' <<<"$line")
			record "$pane" "$status" "$agent"
			;;
		pane.created | pane_created)
			# Resubscribe before an agent starts in the new pane, so its first
			# status change isn't missed.
			if ((${#FIXED_PANES[@]} == 0)); then
				echo "new pane $(jq -r '.data.pane.pane_id // .data.pane_id // "?"' <<<"$line"), resubscribing" >&2
				break
			fi
			;;
		pane.agent_detected | pane_agent_detected)
			pane=$(jq -r '.data.pane_id' <<<"$line")
			if ((${#FIXED_PANES[@]} == 0)) && [[ " ${panes[*]} " != *" $pane "* ]]; then
				# herdr emits the first status change before this event, so
				# snapshot the current state to cover it.
				read -r status agent < <(herdr pane get "$pane" | jq -r '.result.pane | "\(.agent_status) \(.agent // "")"')
				record "$pane" "$status" "$agent"
				echo "new agent in $pane, resubscribing" >&2
				break
			fi
			;;
		"")
			if jq -e '.error' <<<"$line" >/dev/null 2>&1; then
				echo "subscribe failed: $line" >&2
				exit 1
			fi
			;;
		esac
	done <"$FIFO_OUT"

	kill "$NC_PID" 2>/dev/null || true
	wait "$NC_PID" 2>/dev/null || true
	NC_PID=""
	exec 3>&-
	sleep 0.2
done
