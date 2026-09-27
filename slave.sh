#!/usr/bin/env bash
source config.conf

id="$1"
fifo="${SLAVE_PREFIX_FIFO}${id}.fifo"
echo -e "[slave ${id}] \e[33mascult\e[0m din: ${fifo}"
while read -r line; do
        echo -e "[slave $id] \e[34mprimesc\e[0m brut: $line"

        content="${line#*[\[]}"
        content="${content%\]*}"

        pid_client="${content%%:*}"
        comanda="${content#*: }"


        fifo_client="${CLIENT_FIFO}${pid_client}"

        bash -c "$comanda" > "$fifo_client"
        echo -e "[slave ${id}] \e[32mtrimit\e[0m rezultatul la client: ${pid_client}"
done <  "$fifo"
