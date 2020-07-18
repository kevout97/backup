#!/bin/bash

export LD_LIBRARY_PATH=/opt/rh/devtoolset-3/root/usr/lib64/

pgrep named

exit $?