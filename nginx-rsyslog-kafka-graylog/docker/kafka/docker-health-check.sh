#!/bin/bash

# Mauricio Melendez & Kevin Gómez | AMX GA/DT

. /tmp/.env

export LD_LIBRARY_PATH=/opt/rh/devtoolset-3/root/usr/lib64/

PIDS=$(ps ax | grep -i 'kafka\.Kafka' | grep java | grep -v grep | awk '{print $1}')

if [ -z "$PIDS" ]; then
  exit 1
else
  exit 0
fi