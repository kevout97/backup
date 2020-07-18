#!/bin/bash

#Created by Mauricio & Kevs | AMX GADT

export LD_LIBRARY_PATH=/opt/rh/devtoolset-3/root/usr/lib64/

OPENDKIM_PID=$(pgrep opendkim)

if [ -n "${OPENDKIM_PID}" ]; then
    exit 0
fi

exit 1