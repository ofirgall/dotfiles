#!/usr/bin/env bash
payload=$(cat)

jq_or_python() {
  if command -v jq &>/dev/null; then
    echo "$payload" | jq -r "$1"
  else
    echo "$payload" | python3 -c "
import sys, json
d = json.load(sys.stdin)
keys = '$1'.strip('.').split('.')
v = d
for k in keys:
  if isinstance(v, dict):
    v = v.get(k)
  else:
    v = None
    break
if v is None: print('${2:-}')
elif isinstance(v, bool): print(str(v).lower())
else: print(v)
"
  fi
}

model=$(jq_or_python '.model.display_name' 'unknown')
pct_raw=$(jq_or_python '.context_window.used_percentage' '0')
[ "$pct_raw" = "null" ] && pct_raw=0
pct=${pct_raw%%.*}
ctx_size=$(jq_or_python '.context_window.context_window_size' '0')
thinking=$(jq_or_python '.thinking.enabled' 'false')
effort=$(jq_or_python '.effort.level' '')
fast=$(jq_or_python '.fast_mode' 'false')
cost=$(jq_or_python '.cost.total_cost_usd' '0')
session_limit=$(jq_or_python '.rate_limits.five_hour.used_percentage' '0' | cut -d. -f1)
weekly_limit=$(jq_or_python '.rate_limits.seven_day.used_percentage' '0' | cut -d. -f1)

model_id=$(jq_or_python '.model.id' '')

# Auto-compact window isn't in the payload; resolve it like Claude Code does:
# env var > per-model setting > global setting > auto
settings_file="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json"
ac_window="${CLAUDE_CODE_AUTO_COMPACT_WINDOW:-}"
if [ -z "$ac_window" ] && [ -f "$settings_file" ]; then
  ac_window=$(python3 -c "
import sys, json
s = json.load(open(sys.argv[1]))
m = sys.argv[2].split('[')[0]
v = (s.get('modelSettings') or {}).get(m, {}).get('autoCompactWindow', s.get('autoCompactWindow'))
print('' if v is None else v)
" "$settings_file" "$model_id" 2>/dev/null)
fi

if [ -n "${CLAUDE_CONFIG_DIR:-}" ]; then
  account_file="$CLAUDE_CONFIG_DIR/.claude.json"
else
  account_file="$HOME/.claude.json"
fi
user=$(python3 -c "
import sys, json
a = json.load(open(sys.argv[1])).get('oauthAccount') or {}
print(a.get('emailAddress') or '')
" "$account_file" 2>/dev/null)
[ -z "$user" ] && user="$USER"

# When AC window is set, show usage relative to it instead of the full window
if [[ "$ac_window" =~ ^[0-9]+$ ]] && [ "$ac_window" -gt 0 ] && [[ "$ctx_size" =~ ^[0-9]+$ ]]; then
  pct=$(awk -v p="$pct_raw" -v c="$ctx_size" -v a="$ac_window" 'BEGIN { printf "%d", p * c / a }')
  ctx_size=$ac_window
fi

ctx_k=$((ctx_size / 1000))

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

printf "\033[36m%s\033[0m  ${ctx_color}%s%%\033[90m/%sK  \033[33m\$%s \033[90m|\033[0m \033[90mS:\033[0m%s%% \033[90mW:\033[0m%s%% \033[90m|\033[0m \033[35m%s\033[0m" \
  "$label" "$pct" "$ctx_k" "$cost_fmt" "$session_limit" "$weekly_limit" "$user"
