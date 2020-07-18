#!/bin/bash

docker rm -f linotp &>/dev/null

echo "Creando contenedor 'linotp'" 
docker run -itd -p 443:443 --name linotp \
           -e LIN_USER=AMX \
           -e LIN_REALM=AMX \
           -e LIN_PASS=1234 \
           -e DB_HOST=172.17.0.2 \
           -e DB_USER=root \
           -e DB_PASS=mypass \
           -e DB_NAME=AMX-LINOTP \
	   -v /etc/localtime:/etc/localtime:ro \
           linotp:latest

           # export LIN_USER=AMX \
           #LIN_REALM=AMX \
           #LIN_PASS=1234 \
           #DB_HOST=172.17.0.2 \
           #DB_USER=root \
           #DB_PASS=mypass \
           #DB_NAME=AMX-LINOTP \

