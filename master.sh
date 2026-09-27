#!/usr/bin/env bash
source config.conf

cleanup() {
    echo -e "\n[master] Oprire server. Sterg FIFO-uri si inchid sclavii."
    if [ -n "${slave_pids[*]}" ]; then
        kill ${slave_pids[@]} 2>/dev/null
    fi
    rm -f "$WKF"
    rm -f "${SLAVE_PREFIX_FIFO}"*
    exit 0
}

trap cleanup EXIT INT TERM

rm -f "$WKF"
mkfifo "$WKF"

slave_pids=()
declare -a slave_fds

for ((i=1; i<=SLAVES; i++)); do
    fifo="${SLAVE_PREFIX_FIFO}${i}.fifo"
    rm -f "$fifo"
    mkfifo "$fifo"

    ./slave.sh "$i" &
    slave_pids+=($!)

    exec {fd}>"$fifo"
    slave_fds[$i]=$fd
done

echo "[master] Serverul asculta. Gata de treaba!"

exec 3<> "$WKF"

current_slave=1

while read -r line <&3; do
    target_fd=${slave_fds[$current_slave]}

    echo "$line" >&${target_fd}

    ((current_slave++))
    if [ "$current_slave" -gt "$SLAVES" ]; then
        current_slave=1
    fi
done
