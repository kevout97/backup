#!/bin/bash

## Habilita el trafico de los siguientes puertos
# 50000 (si la base de datos tambien estara en ese servidor)
# 80
# 443

## Despliegue de contenedor DB2
instancia=db2amx
mkdir -p /var/containers/db2/$instancia/home/
docker run -td --hostname=db2105.service \
    --privileged=true \
    --name db2105 \
    --cap-add=IPC_OWNER \
    -p 50000:50000 \
    -v /etc/localtime:/etc/localtime:ro \
    --volume=/var/containers/db2/$instancia/home/:/home/ \
    -e "instuser=$instancia" \
    -e "instport=50000" \
    -e "instpasswd=mipasswordmuysecreto" \
    --entrypoint /root/entrypoint.sh \
    --ulimit nofile=102400:102400 \
    dockeregistry.amovildigitalops.com/rhel68db2105:v1.0

docker run -itd --name mydb2 \
    --privileged=true \
    -p 50000:50000 \
    -e LICENSE=accept \
    -e DB2INST1_PASSWORD=<choose an instance password> \
    -e DBNAME=testdb \
    -v <db storage dir>:/database \
    ibmcom/db2

## Creacion de la base de datos
### Ingresamo al contenedor
docker exec -it --user db2amx db2105 /opt/IBM/db2/V10.5/bin/db2

## Creamos la base de datos
create database MFPDATA
drop database MFPDATA

## Despliegue de mobilefirst
MFPF_CONTAINER="mobilefirst-farm" # Nombre del contenedor
MFPF_DOMAIN="mfp.san.gadt.amxdigital.net" # Dominio con el que se expondra mfp
MFPF_IP_SERVER="10.23.142.134" # Ip del servidor donde estará desplegado mfp, debe ser el de la vlan por el que se comnunicará con los otros nodos
MFPF_DB2_PORT="50000" # Puerto de db2
MFPF_DB2_HOST="10.23.142.134" # Ip o Hostname de db2
MFPF_DB2_USER="db2amx" # Usuario de db2
MFPF_DB2_PASSWORD="mipasswordmuysecreto" # Password de db2
MFPF_DB2_DATABASE="MFPDATA" # Nombre de la base de datos
MFPF_USER="amxga" # Primer usuario para ingresar a Mfp
MFPF_USER_PASSWORD="abcd1234" # Password del usuario de arriba
MFPF_ADMIN_USER="amxgaadmin" # Con este usuario tambien se puede acceder, pero a su vez Mfp lo usa internamente para comunicaciones (debe ser el mismo en todos los nodos)
MFPF_ADMIN_USER_PASSWORD="abcd12345" # Password del usuario de arriba (debe ser el mismo en todos los nodos)
ANALYTICS_ADMIN_USER="analitics" # Usuario del servicio Analytics (No es relevante pero no puede ir en blanco, si el Analytics no esta arriba puedes poner lo que sea)
ANALYTICS_ADMIN_PASSWORD="abcd123" # Password del usuario de arriba (No es relevante pero no puede ir en blanco, si el Analytics no esta arriba puedes poner lo que sea)
ANALYTICS_URL="http://10.23.143.8:9082" # Ip o hostname del Abalytics (No es relevante pero no puede ir en blanco, si el Analytics no esta arriba puedes poner lo que sea)
MFPF_SERVER_ID="amxga-farm1" # Este es un ID que se le asocia a este nodo de Mfp, debe ser unico para cada nodo

docker run -td --privileged=true --name $MFPF_CONTAINER \
    -p 80:80 -p 443:443 \
    -v /var/containers/$MFPF_CONTAINER/opt/ibm/wlp/usr/servers/:/opt/ibm/wlp/usr/servers/:z \
    -v /etc/localtime:/etc/localtime:ro \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    --health-cmd='/sbin/docker-health-check.sh' \
    --health-interval=10s \
    --restart unless-stopped \
    -h $MFPF_DOMAIN \
    -e TZ=America/Mexico_City \
    -e "IP_ADDRESS=$MFPF_IP_SERVER" \
    -e "MFPF_SERVER_HTTPPORT=80" \
    -e "MFPF_SERVER_HTTPSPORT=443" \
    -e "MFPF_DB2_SERVER_NAME=$MFPF_DB2_HOST" \
    -e "MFPF_DB2_PORT=$MFPF_DB2_PORT" \
    -e "MFPF_DB2_DATABASE_NAME=$MFPF_DB2_DATABASE" \
    -e "MFPF_DB2_USERNAME=$MFPF_DB2_USER" \
    -e "MFPF_DB2_PASSWORD=$MFPF_DB2_PASSWORD" \
    -e "MFPF_USER=$MFPF_USER" \
    -e "MFPF_USER_PASSWORD=$MFPF_USER_PASSWORD" \
    -e "MFPF_ADMIN_USER=$MFPF_ADMIN_USER" \
    -e "MFPF_ADMIN_USER_PASSWORD=$MFPF_ADMIN_USER_PASSWORD" \
    -e "ANALYTICS_ADMIN_USER=$ANALYTICS_ADMIN_USER" \
    -e "ANALYTICS_ADMIN_PASSWORD=$ANALYTICS_ADMIN_PASSWORD" \
    -e "ANALYTICS_URL=$ANALYTICS_URL" \
    -e "MFPF_CLUSTER_MODE=Farm" \
    -e "MFPF_SERVER_ID=$MFPF_SERVER_ID" \
    dockeregistry.amovildigitalops.com/rhel7-atomic-mfpserverfarm
