#!/bin/bash

. /tmp/.env

export LD_LIBRARY_PATH=/opt/rh/devtoolset-3/root/usr/lib64/

/opt/sonatype/app/nexus/bin/nexus status

exit $?