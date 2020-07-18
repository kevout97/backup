#!/bin/bash

REDIS_PID=$(cat /var/run/redis_6379.pid)

if [ -n "${REDIS_PID}" ]; then
    exit 0
else
    exit 1
fi