#!/bin/bash

set -euo pipefail

export DEBUG=ioredis:cluster

while true
do
    "$@"
done
