# FIFO-RSHD: Remote Shell Daemon using Named Pipes

A lightweight remote shell execution system written in Bash that uses Linux named pipes (FIFOs) for inter-process communication (IPC).
The project implements a master-worker architecture where a master daemon balances execution requests across a pool of slave processes using Round-Robin scheduling.

## How It Works

1. Client (client.sh):
   - Retrieves its own process ID ($$) and creates a personal reply FIFO (/tmp/client-<PID>).
   - Encapsulates the user command in the format BEGIN-REQ [client-pid: command] END-REQ and writes it to the well-known master FIFO ($WKF).
   - Reads the output from its personal FIFO and automatically deletes the pipe on exit via trap.

2. Master Server (master.sh):
   - Reads settings from config.conf.
   - Creates the master FIFO ($WKF) and worker pipes ($SLAVE_PREFIX_FIFO<i>.fifo), spawning SLAVES background worker instances.
   - Keeps pipes open using persistent file descriptors (exec {fd}>... and exec 3<>...) to avoid blocking.
   - Forwards each incoming request to the next worker in a Round-Robin loop (current_slave++).
   - Cleans up child processes and removes all server pipes on SIGINT / SIGTERM.

3. Workers (slave.sh):
   - Listen on their assigned pipe.
   - Parse the request to extract the client's PID and shell command.
   - Execute the command via bash -c and redirect standard output to the client's personal FIFO ($CLIENT_FIFO$pid_client).

## Configuration (config.conf)

WKF=/tmp/rshd-master.fifo
SLAVE_PREFIX_FIFO=/tmp/rshd-slave-
CLIENT_FIFO=/tmp/client-
SLAVES=4

## How to Run

1. Set execution permissions:
chmod +x master.sh slave.sh client.sh

2. Start the Master Server:
./master.sh

3. Send Commands via Clients:
./client.sh ls -la
./client.sh pwd
./client.sh ls -l | wc -l

4. Stop the Server:
Press Ctrl + C in the master terminal. The cleanup trap will terminate all worker processes and delete the FIFO files from /tmp.
