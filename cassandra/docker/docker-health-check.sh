#!/bin/bash

# Mauricio Melendez & Kevin Gómez | AMX GA/DT

export LD_LIBRARY_PATH=/opt/rh/devtoolset-3/root/usr/lib64/

CASSANDRA_PID=$(cat $CASSANDRA_FILE_PID)

if [ -n "${CASSANDRA_PID}" ]; then
    exit 0
else
    exit 1
fi