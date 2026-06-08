#!/usr/bin/env bash
payload=$(cat)

model=$(echo "$payload" | jq -r '.model.display_name // "unknown"')
params=$(echo "$payload" | jq -r '.model.param_summary // empty')
max_mode=$(echo "$payload" | jq -r '.model.max_mode // false')
pct=$(echo "$payload" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
ctx_size=$(echo "$payload" | jq -r '.context_window.context_window_size // 0')
autorun=$(echo "$payload" | jq -r '.autorun // false')
vim_mode=$(echo "$payload" | jq -r '.vim.mode // empty')

ctx_k=$((ctx_size / 1000))

label="$model"
[ -n "$params" ] && [[ "$label" != *"$params"* ]] && label="$label $params"
[ "$max_mode" = "true" ] && label="$label [MAX]"

if [ "$pct" -ge 80 ]; then
  ctx_color="\033[31m"
elif [ "$pct" -ge 60 ]; then
  ctx_color="\033[33m"
else
  ctx_color="\033[32m"
fi

if [ "$autorun" = "true" ]; then
  ar="\033[35mAuto-Run\033[0m"
else
  ar="\033[31mRequires-Perm\033[0m"
fi

vim=""
if [ -n "$vim_mode" ]; then
  if [ "$vim_mode" = "NORMAL" ]; then
    vim="\033[34m$vim_mode\033[0m"
  else
    vim="\033[33m$vim_mode\033[0m"
  fi
fi

printf "\033[36m%s\033[0m  ${ctx_color}%s%%\033[90m/%sK\033[0m  %b  %b" \
  "$label" "$pct" "$ctx_k" "$ar" "$vim"
