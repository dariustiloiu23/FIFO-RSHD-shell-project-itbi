#!/usr/bin/env bash
source config.conf

pid=$$
reply="${CLIENT_FIFO}${pid}"
trap 'rm -f "$reply"' EXIT INT TERM
rm -f "$reply"
mkfifo "$reply"

cmd="$*"
echo "BEGIN-REQ [${pid}: ${cmd}] END-REQ" > "$WKF"
cat "$reply"
