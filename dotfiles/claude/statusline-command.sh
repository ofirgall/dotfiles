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
pct=$(jq_or_python '.context_window.used_percentage' '0' | cut -d. -f1)
ctx_size=$(jq_or_python '.context_window.context_window_size' '0')
thinking=$(jq_or_python '.thinking.enabled' 'false')
effort=$(jq_or_python '.effort.level' '')
fast=$(jq_or_python '.fast_mode' 'false')
cost=$(jq_or_python '.cost.total_cost_usd' '0')
duration_ms=$(jq_or_python '.cost.total_duration_ms' '0')
session_limit=$(jq_or_python '.rate_limits.five_hour.used_percentage' '0' | cut -d. -f1)
weekly_limit=$(jq_or_python '.rate_limits.seven_day.used_percentage' '0' | cut -d. -f1)

ctx_k=$((ctx_size / 1000))
duration_min=$((duration_ms / 60000))

label="$model"
[ "$thinking" = "true" ] && label="$label Thinking"
[ "$fast" = "true" ] && label="$label Fast"
[ -n "$effort" ] && label="$label ${effort^}"

if [ "$pct" -ge 80 ]; then
  ctx_color="\033[31m"
elif [ "$pct" -ge 60 ]; then
  ctx_color="\033[33m"
else
  ctx_color="\033[32m"
fi

cost_fmt=$(printf '%.2f' "$cost" 2>/dev/null || echo "$cost")

printf "\033[36m%s\033[0m  ${ctx_color}%s%%\033[90m/%sK\033[0m  \033[33m\$%s \033[90m(%sm)\033[0m \033[90m|\033[0m \033[90mS:\033[0m%s%%  \033[90mW:\033[0m%s%%" \
  "$label" "$pct" "$ctx_k" "$cost_fmt" "$duration_min" "$session_limit" "$weekly_limit"
