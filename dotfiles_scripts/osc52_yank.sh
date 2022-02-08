#!/bin/sh

# get data either form stdin or from file
buf=$(cat "$@") # Get buffer length
buflen=$( printf %s "$buf" | wc -c )

maxlen=74994
# warn if exceeds maxlen
if [ "$buflen" -gt "$maxlen" ]; then
   printf "input is %d bytes too long" "$(( buflen - maxlen ))" >&2
fi

# build up OSC 52 ANSI escape sequence
esc="\033]52;c;$( printf %s "$buf" | head -c $maxlen | base64 | tr -d '\r\n' )\a"
printf $esc # Send the OSC52 sequence
