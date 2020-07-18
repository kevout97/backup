#!/bin/bash

 docker rm -f spacewalk &>/dev/null
echo "Creando contenedor 'spacewalk'" 
docker run -itd --name spacewalk -p 80:80 -p 443:443\
           -e DB_HOST=172.17.0.3 \
           -e DB_USER=spaceuser \
           -e DB_PASS=spacepw \
           -e DB_NAME=spaceschema \
 	   -v /etc/localtime:/etc/localtime:ro \
           spacewalk:latest 

