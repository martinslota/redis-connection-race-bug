# Race condition in `ioredis` and `iovalkey` when reconnecting to a cluster

Minimal-ish reproduce of a race condition in
[`ioredis`](https://github.com/redis/ioredis) and
[`iovalkey`](https://github.com/valkey-io/iovalkey) when reconnecting to nodes
running in cluster mode.

See [reproduce-ioredis.js](reproduce-ioredis.js) and
[reproduce-iovalkey.js](reproduce-iovalkey.js) for code that triggers the race
condition.

## Prerequisites

- [Docker Compose](https://docs.docker.com/compose/)
- [Bash](https://www.gnu.org/software/bash/)
- No process bound to local ports `6080 - 6082` and `6090 - 6092`

## Reproduce bug in `ioredis`

To reproduce the bug in `ioredis`, run `npm run reproduce-ioredis`. The output should look something like this:

```sh
$ npm run reproduce-ioredis

> redis-connection-race-bug@1.0.0 reproduce-ioredis
> docker compose up --wait && ./loop.sh node reproduce-ioredis.js

[+] Running 2/2
 ✔ Container redis-connection-race-bug-redis-cluster-1   Healthy                                                                                                                                                                                                                                                                                                                                                   0.5s
 ✔ Container redis-connection-race-bug-valkey-cluster-1  Healthy                                                                                                                                                                                                                                                                                                                                                   0.5s
  ioredis:cluster status: [empty] -> connecting +0ms
  ioredis:cluster resolved hostname localhost to IP 127.0.0.1 +7ms
  ioredis:cluster getting slot cache from 127.0.0.1:6380 +0ms
  ioredis:cluster cluster slots result count: 3 +5ms
  ioredis:cluster cluster slots result [0]: slots 0~5460 served by [ '127.0.0.1:6380' ] +0ms
  ioredis:cluster cluster slots result [1]: slots 5461~10922 served by [ '127.0.0.1:6381' ] +1ms
  ioredis:cluster cluster slots result [2]: slots 10923~16383 served by [ '127.0.0.1:6382' ] +0ms
  ioredis:cluster status: connecting -> connect +2ms
  ioredis:cluster status: connect -> ready +4ms
  ioredis:cluster send 1 commands in offline queue +0ms
  ioredis:cluster status: ready -> disconnecting +3ms
  ioredis:cluster status: disconnecting -> disconnecting +1ms
  ioredis:cluster status: disconnecting -> close +0ms
  ioredis:cluster status: close -> end +0ms
  ioredis:cluster status: end -> connecting +0ms
  ioredis:cluster status: connecting -> close +1ms
  ioredis:cluster resolved hostname localhost to IP 127.0.0.1 +0ms
  ioredis:cluster discard connecting after resolving startup nodes because the status changed to close +0ms
/path/to/redis-connection-race-bug/node_modules/ioredis/built/cluster/index.js:125
                    reject(new redis_errors_1.RedisError("Connection is aborted"));
                           ^

RedisError: Connection is aborted
    at /path/to/redis-connection-race-bug/node_modules/ioredis/built/cluster/index.js:125:28

Node.js v20.14.0
```

## Reproduce bug in `iovalkey`

To reproduce the bug in `iovalkey`, run `npm run reproduce-iovalkey`. The output should look something like this:

```sh
$ npm run reproduce-iovalkey

> redis-connection-race-bug@1.0.0 reproduce-iovalkey
> docker compose up --wait && ./loop.sh node reproduce-iovalkey.js

[+] Running 2/2
 ✔ Container redis-connection-race-bug-valkey-cluster-1  Healthy                                                                                                                                                                                                                                                                                                                                                   0.5s
 ✔ Container redis-connection-race-bug-redis-cluster-1   Healthy                                                                                                                                                                                                                                                                                                                                                   0.5s
  ioredis:cluster status: [empty] -> connecting +0ms
  ioredis:cluster resolved hostname localhost to IP 127.0.0.1 +6ms
  ioredis:cluster getting slot cache from 127.0.0.1:6390 +1ms
  ioredis:cluster cluster slots result count: 3 +4ms
  ioredis:cluster cluster slots result [0]: slots 0~5460 served by [ '127.0.0.1:6390' ] +0ms
  ioredis:cluster cluster slots result [1]: slots 5461~10922 served by [ '127.0.0.1:6391' ] +1ms
  ioredis:cluster cluster slots result [2]: slots 10923~16383 served by [ '127.0.0.1:6392' ] +0ms
  ioredis:cluster status: connecting -> connect +2ms
  ioredis:cluster status: connect -> ready +4ms
  ioredis:cluster send 1 commands in offline queue +0ms
  ioredis:cluster status: ready -> disconnecting +3ms
  ioredis:cluster status: disconnecting -> disconnecting +1ms
  ioredis:cluster status: disconnecting -> close +1ms
  ioredis:cluster status: close -> end +0ms
  ioredis:cluster status: end -> connecting +0ms
  ioredis:cluster status: connecting -> close +0ms
  ioredis:cluster resolved hostname localhost to IP 127.0.0.1 +0ms
  ioredis:cluster discard connecting after resolving startup nodes because the status changed to close +0ms
/path/to/redis-connection-race-bug/node_modules/iovalkey/built/cluster/index.js:124
                    reject(new redis_errors_1.RedisError("Connection is aborted"));
                           ^

RedisError: Connection is aborted
    at /path/to/redis-connection-race-bug/node_modules/iovalkey/built/cluster/index.js:124:28

Node.js v20.14.0
```
