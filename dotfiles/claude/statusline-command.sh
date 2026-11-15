#!/usr/bin/env bash
# Claude Code status line.
#
# Context is shown against the real auto-compact point, resolved the way
# Claude Code (2.1.x) does it:
#   window    = min(model window, autoCompactWindow)   (env > settings > model window)
#   effective = window - min(maxOutputTokens, 20000)   (20000 for current models)
#   threshold = effective - 13000
#               or min(effective * CLAUDE_AUTOCOMPACT_PCT_OVERRIDE / 100, effective - 13000)
# Server-side experiments that change the default window can't be seen from here.
payload=$(cat)

# Prefer a jq that doesn't go through asdf shims: those fail in directories
# whose .tool-versions doesn't pin jq.
JQ=""
for cand in /usr/bin/jq /opt/homebrew/bin/jq /usr/local/bin/jq jq; do
  if "$cand" --version >/dev/null 2>&1; then JQ=$cand; break; fi
done
if [ -z "$JQ" ]; then
  printf 'statusline: jq not found'
  exit 0
fi

get() { "$JQ" -r "($1) // empty" <<<"$payload" 2>/dev/null; }

model=$(get '.model.display_name'); model=${model:-unknown}
model_id=$(get '.model.id')
ctx_size=$(get '.context_window.context_window_size')
used_tokens=$(get '.context_window.total_input_tokens')
pct_raw=$(get '.context_window.used_percentage')
thinking=$(get '.thinking.enabled')
effort=$(get '.effort.level')
fast=$(get '.fast_mode')
cost=$(get '.cost.total_cost_usd'); cost=${cost:-0}
session_limit=$(get '.rate_limits.five_hour.used_percentage | floor')
weekly_limit=$(get '.rate_limits.seven_day.used_percentage | floor')
project_dir=$(get '.workspace.project_dir')
[ -z "$project_dir" ] && project_dir=$(get '.workspace.current_dir')

[[ "$ctx_size" =~ ^[0-9]+$ ]] || ctx_size=0
if ! [[ "$used_tokens" =~ ^[0-9]+$ ]]; then
  # Older payloads: derive tokens from the percentage.
  used_tokens=$(awk -v p="${pct_raw:-0}" -v c="$ctx_size" 'BEGIN { printf "%d", p * c / 100 }')
fi

# --- Resolve autoCompactWindow / autoCompactEnabled from every settings layer.
config_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
settings_files=("$config_dir/settings.json")
if [ -n "$project_dir" ]; then
  settings_files+=("$project_dir/.claude/settings.json" "$project_dir/.claude/settings.local.json")
fi
settings_files+=("/Library/Application Support/ClaudeCode/managed-settings.json")

model_key=${model_id%%\[*}
ac_raw=""
ac_enabled="true"
for f in "${settings_files[@]}"; do
  [ -f "$f" ] || continue
  # Later files have higher precedence; within a file, per-model beats top-level.
  v=$("$JQ" -r --arg full "$model_id" --arg key "$model_key" '
      (.modelSettings[$full].autoCompactWindow // .modelSettings[$key].autoCompactWindow
       // .autoCompactWindow) // empty' "$f" 2>/dev/null)
  [ -n "$v" ] && ac_raw=$v
  e=$("$JQ" -r 'if has("autoCompactEnabled") then .autoCompactEnabled else empty end' "$f" 2>/dev/null)
  [ -n "$e" ] && ac_enabled=$e
done
[ -n "${CLAUDE_CODE_AUTO_COMPACT_WINDOW:-}" ] && ac_raw=$CLAUDE_CODE_AUTO_COMPACT_WINDOW

# Parse "auto", 200000, "200k", "1m", or a bare 200 meaning 200k.
parse_tokens() {
  local s
  s=$(tr '[:upper:]' '[:lower:]' <<<"$1" | tr -d ' _,')
  case "$s" in
    ""|auto|default|reset|unset) return 1 ;;
  esac
  awk -v s="$s" 'BEGIN {
    if (s ~ /^[0-9]+(\.[0-9]+)?k$/) n = substr(s, 1, length(s) - 1) * 1000
    else if (s ~ /^[0-9]+(\.[0-9]+)?m$/) n = substr(s, 1, length(s) - 1) * 1000000
    else if (s ~ /^[0-9]+$/) { n = s + 0; if (n <= 1000) n *= 1000 }
    else exit 1
    if (n < 100000) n = 100000
    if (n > 1000000) n = 1000000
    printf "%d", n
  }'
}

window=$ctx_size
if ac_tokens=$(parse_tokens "$ac_raw"); then
  if [ "$window" -eq 0 ] || [ "$ac_tokens" -lt "$window" ]; then
    window=$ac_tokens
  fi
fi

effective=$((window - 20000))
threshold=$((effective - 13000))
pct_override=${CLAUDE_AUTOCOMPACT_PCT_OVERRIDE:-}
if [[ "$pct_override" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
  threshold=$(awk -v e="$effective" -v p="$pct_override" -v t="$threshold" \
    'BEGIN { if (p > 0 && p <= 100) { x = int(e * p / 100); if (x < t) t = x }; printf "%d", t }')
fi

if [ "$ac_enabled" = "false" ] || [ "$threshold" -le 0 ]; then
  limit=$ctx_size
  ac_tag=" AC:off"
else
  # Show the configured window (e.g. 300K), not the compaction point inside it.
  limit=$window
  ac_tag=""
fi

if [ "$limit" -gt 0 ]; then
  pct=$((used_tokens * 100 / limit))
else
  pct=0
fi
[ "$pct" -gt 100 ] && pct=100
limit_k=$((limit / 1000))

account_file="$config_dir/.claude.json"
[ -z "${CLAUDE_CONFIG_DIR:-}" ] && account_file="$HOME/.claude.json"
user=$("$JQ" -r '.oauthAccount.emailAddress // empty' "$account_file" 2>/dev/null)
[ -z "$user" ] && user="$USER"

label="$model"
[ "$thinking" = "true" ] && label="$label Thinking"
[ "$fast" = "true" ] && label="$label Fast"
[ -n "$effort" ] && label="$label $(tr '[:lower:]' '[:upper:]' <<< "${effort:0:1}")${effort:1}"

if [ "$pct" -ge 80 ]; then
  ctx_color="\033[31m"
elif [ "$pct" -ge 60 ]; then
  ctx_color="\033[33m"
else
  ctx_color="\033[32m"
fi

cost_fmt=$(printf '%.2f' "$cost" 2>/dev/null || echo "$cost")

printf "\033[36m%s\033[0m  ${ctx_color}%s%%\033[90m/%sK%s  \033[33m\$%s \033[90m|\033[0m \033[90mS:\033[0m%s%% \033[90mW:\033[0m%s%% \033[90m|\033[0m \033[35m%s\033[0m" \
  "$label" "$pct" "$limit_k" "$ac_tag" "$cost_fmt" "${session_limit:-0}" "${weekly_limit:-0}" "$user"
