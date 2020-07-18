#!/bin/bash

PROJECT=$(pwd | awk -F/ '{print $NF}')

docker build -t dockeregistry.amovildigitalops.com/${PROJECT}  . 2>&1 | tee -a le_build.log

exit $?

