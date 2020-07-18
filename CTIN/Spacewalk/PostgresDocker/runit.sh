#!/bin/bash

if [ 1 -eq $(docker ps -a | grep -w postgres &>/dev/null && echo 1 || echo 0) ]; then
 echo "El contenedor 'postgres' ya existente. Eliminando contenedor"
 docker rm -f postgres &>/dev/null
 rm -rf /var/containers/postgres/var/lib/pgsql/data/*
fi
echo "Creando contenedor 'postgres'"
mkdir -p /var/containers/postgres/var/lib/pgsql/data

docker run -itd --name postgres \
                -e DB_NAME=spaceschema \
                -e DB_USER=spaceuser \
                -e DB_PASS=spacepw \
                -e https_proxy="https://10.0.202.7:8080" \
                -e http_proxy="http://10.0.202.7:8080" \
		-v /var/containers/postgres/var/lib/pgsql/data:/var/lib/pgsql/data:z \
		postgres-spacewalk:latest 

#               --volume=/var/containers/postgres/var/lib/pgsql/data:/var/lib/pgsql/data:z \

