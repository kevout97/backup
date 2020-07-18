#!/bin/bash


PROJECT=$(pwd | awk -F/ '{print $NF}')

docker push dockeregistry.amovildigitalops.com/${PROJECT}
docker rmi $(docker images -qa -f "dangling=true") 2>/dev/null

