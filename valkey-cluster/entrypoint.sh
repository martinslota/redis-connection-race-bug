#!/bin/sh

if [ "$1" = 'valkey-cluster' ]; then
    if [ -z "$IP" ]
    then
      IP=$(hostname -I)
    fi
    IP=${IP%% *}

    INITIAL_PORT=${INITIAL_PORT:-7000}
    MASTERS=3
    SLAVES_PER_MASTER=${SLAVES_PER_MASTER:-1}
    BIND_ADDRESS=0.0.0.0
    MAX_PORT=$((INITIAL_PORT + MASTERS * ( SLAVES_PER_MASTER + 1 ) - 1))
    CREATE_CLUSTER=false

    if [ ! -d /data/valkey-conf ]; then
      CREATE_CLUSTER=true

      for PORT in $(seq "$INITIAL_PORT" "$MAX_PORT"); do
        mkdir -p "/data/valkey-conf/${PORT}"
        mkdir -p "/data/${PORT}"

        PORT=${PORT} BIND_ADDRESS=${BIND_ADDRESS} envsubst < /valkey-cluster.tmpl > "/data/valkey-conf/${PORT}/valkey.conf"
        NODES="$NODES $IP:$PORT"
      done
    fi

    bash /generate-supervisor-conf.sh "$INITIAL_PORT" "$MAX_PORT" > /etc/supervisor/supervisord.conf

    supervisord -c /etc/supervisor/supervisord.conf &
    sleep 3

    if [ "$CREATE_CLUSTER" = true ]; then
      echo "yes" | eval /usr/local/bin/valkey-cli --cluster create --cluster-replicas "$SLAVES_PER_MASTER" "$NODES"
    fi

    tail -f /var/log/supervisor/valkey*.log
else
  exec "$@"
fi
