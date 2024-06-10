#!/bin/bash

initial_port="$1"
max_port="$2"

program_entry_template ()
{
  local count=$1
  local port=$2
  echo "

[program:valkey-$count]
command=/usr/local/bin/valkey-server /data/valkey-conf/$port/valkey.conf
stdout_logfile=/var/log/supervisor/%(program_name)s.log
stderr_logfile=/var/log/supervisor/%(program_name)s.log
autorestart=true
"
}

result_str="
[supervisord]
logfile=/supervisord.log                        ; supervisord log file
logfile_maxbytes=50MB                           ; maximum size of logfile before rotation
logfile_backups=10                              ; number of backed up logfiles
loglevel=error                                  ; info, debug, warn, trace
pidfile=/var/run/supervisord.pid                ; pidfile location
nodaemon=true                                   ; do not run supervisord as a daemon
minfds=1024                                     ; number of startup file descriptors
minprocs=200                                    ; number of process descriptors
user=root                                       ; default user
childlogdir=/                                   ; where child log files will live
"

count=1
for port in $(seq "$initial_port" "$max_port"); do
  result_str="$result_str$(program_entry_template "$count" "$port")"
  count=$((count + 1))
done

echo "$result_str"
