#!/bin/bash

# Mauricio Melendez & Kevin Gómez | AMX GA/DT

. /tmp/.env

export LD_LIBRARY_PATH=/opt/rh/devtoolset-3/root/usr/lib64/

kong health -p $KONG_DIRECTORY 1&>/dev/null

exit $?