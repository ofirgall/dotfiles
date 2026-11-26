#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: codex-latest-plan.sh [OPTIONS] [DIR]

Extract the latest completed Codex Plan Mode plan for DIR as Markdown.

Arguments:
  DIR                     Directory to match against Codex rollout cwd entries.
                          Defaults to the current working directory.

Options:
  -o, --output PATH       Markdown output path. Use "-" for stdout.
                          Defaults to stdout.
      --codex-home PATH   Codex home directory. Defaults to CODEX_HOME or ~/.codex.
  -h, --help              Show this help.
EOF
}

die() {
  echo "codex-latest-plan: $*" >&2
  exit 1
}

codex_home="${CODEX_HOME:-$HOME/.codex}"
output="-"
target_dir=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -o|--output)
      [[ $# -ge 2 ]] || die "$1 requires a path"
      output="$2"
      shift 2
      ;;
    --codex-home)
      [[ $# -ge 2 ]] || die "$1 requires a path"
      codex_home="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      die "unknown option: $1"
      ;;
    *)
      [[ -z "$target_dir" ]] || die "only one DIR argument is supported"
      target_dir="$1"
      shift
      ;;
  esac
done

if [[ $# -gt 0 ]]; then
  [[ -z "$target_dir" ]] || die "only one DIR argument is supported"
  target_dir="$1"
  shift
fi
[[ $# -eq 0 ]] || die "unexpected extra arguments"

command -v jq >/dev/null 2>&1 || die "jq is required"

target_dir="${target_dir:-$PWD}"
[[ -d "$target_dir" ]] || die "directory does not exist: $target_dir"
target_dir="$(cd "$target_dir" && pwd -P)"

sessions_dir="$codex_home/sessions"
[[ -d "$sessions_dir" ]] || die "Codex sessions directory does not exist: $sessions_dir"

read_rollout() {
  local rollout="$1"

  if [[ "$rollout" == *.jsonl.zst ]]; then
    if command -v zstdcat >/dev/null 2>&1; then
      zstdcat -- "$rollout"
    elif command -v zstd >/dev/null 2>&1; then
      zstd -dc -- "$rollout"
    else
      return 2
    fi
  else
    cat -- "$rollout"
  fi
}

extract_latest_plan_json() {
  local rollout="$1"

  read_rollout "$rollout" | jq -crs --arg cwd "$target_dir" '
    def matching_cwd($cwd):
      any(.[]; (.type == "session_meta" or .type == "turn_context")
        and (.payload.cwd? == $cwd));

    if matching_cwd($cwd) then
      [
        .[]
        | select(.type == "event_msg"
            and .payload.type == "item_completed"
            and .payload.item.type == "Plan")
        | {
            completed_at_ms: (.payload.completed_at_ms // 0),
            timestamp: (.timestamp // ""),
            text: .payload.item.text
          }
      ]
      | last // empty
    else
      empty
    end
  '
}

rollouts=()
while IFS= read -r -d '' rollout; do
  if [[ "$rollout" == *.jsonl.zst && -f "${rollout%.zst}" ]]; then
    continue
  fi
  rollouts+=("$rollout")
done < <(find "$sessions_dir" -type f \( -name 'rollout-*.jsonl' -o -name 'rollout-*.jsonl.zst' \) -print0)

[[ ${#rollouts[@]} -gt 0 ]] || die "no rollout files found under $sessions_dir"

best_json=""
best_completed_at_ms=-1
best_timestamp=""

for rollout in "${rollouts[@]}"; do
  candidate_json=""
  if ! candidate_json="$(extract_latest_plan_json "$rollout")"; then
    if [[ "$rollout" == *.jsonl.zst ]]; then
      continue
    fi
    continue
  fi
  [[ -n "$candidate_json" ]] || continue

  candidate_completed_at_ms="$(jq -r '.completed_at_ms // 0' <<<"$candidate_json")"
  candidate_timestamp="$(jq -r '.timestamp // ""' <<<"$candidate_json")"

  if (( candidate_completed_at_ms > best_completed_at_ms )) ||
    { (( candidate_completed_at_ms == best_completed_at_ms )) &&
      [[ "$candidate_timestamp" > "$best_timestamp" ]]; }; then
    best_json="$candidate_json"
    best_completed_at_ms="$candidate_completed_at_ms"
    best_timestamp="$candidate_timestamp"
  fi
done

[[ -n "$best_json" ]] || die "no completed Plan Mode plans found for cwd: $target_dir"

plan_text="$(jq -r '.text' <<<"$best_json")"

if [[ "$output" == "-" ]]; then
  printf '%s\n' "$plan_text"
else
  mkdir -p -- "$(dirname -- "$output")"
  printf '%s\n' "$plan_text" > "$output"
fi
