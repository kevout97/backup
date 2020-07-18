#!/bin/bash

###########################################
#                                         #
#           Runit Keycloak                #
#                                         #
###########################################

KEYCLOAK_CONTAINER="keycloak"
KEYCLOAK_VERSION="9.0.3"
DB_IP=172.17.0.5



#docker rm -f keycloak_db
#docker run -d --name keycloak_db -e MYSQL_USER=myadmin -e MYSQL_PASSWORD=abc123 -e MYSQL_DATABASE=keycloak registry.redhat.io/rhscl/mysql-57-rhel7:5.7

docker rm -f keycloak
#rm -rf /var/containers/keycloak/
DB_IP=$(docker inspect  keycloak_db -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')

mkdir -p /var/containers/$KEYCLOAK_CONTAINER/opt/keycloak-${KEYCLOAK_VERSION}/standalone/{data,log}
chown 500:500 -R /var/containers/$KEYCLOAK_CONTAINER/opt/keycloak-${KEYCLOAK_VERSION}

# Despliegue de Keycloak
docker run -itd --name $KEYCLOAK_CONTAINER --hostname $KEYCLOAK_CONTAINER.service \
    --restart unless-stopped \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -v /var/containers/${KEYCLOAK_CONTAINER}/opt/keycloak-${KEYCLOAK_VERSION}/standalone/data:/opt/keycloak-${KEYCLOAK_VERSION}/standalone/data:z \
    -v /var/containers/${KEYCLOAK_CONTAINER}/opt/keycloak-${KEYCLOAK_VERSION}/standalone/log:/opt/keycloak-${KEYCLOAK_VERSION}/standalone/log:z \
    -e TZ=America/Mexico_City \
    -e "KEYCLOAK_AJP_PORT=8009" \
    -e "KEYCLOAK_HTTP_PORT=8080" \
    -e "KEYCLOAK_HTTPS_PORT=8443" \
    -e "KEYCLOAK_MANAGEMENT_HTTP_PORT=9990" \
    -e "KEYCLOAK_MANAGEMENT_HTTPS_PORT=9993" \
    -e "KEYCLOAK_BIN_ADDRESS_MANAGEMENT=0.0.0.0" \
    -e "KEYCLOAK_BIN_ADDRESS=0.0.0.0" \
    -e "KEYCLOAK_MYSQL_HOST=galera-cluster.cygnus3.io" \
    -e "KEYCLOAK_MYSQL_PORT=3306" \
    -e "KEYCLOAK_MYSQL_DATABASE=keycloak" \
    -e "KEYCLOAK_MYSQL_USER=myadmin" \
    -e 'KEYCLOAK_MYSQL_PASSWORD=abc123' \
    -e "KEYCLOAK_ADMIN_USER=admin" \
    -e "KEYCLOAK_ADMIN_PASSWORD=abcd123#" \
    -e "JGROUPS_DISCOVERY_PROTOCOL=JDBC_PIN" \
    -e "JGROUPS_DISCOVERY_PROPERTIES=" \
    -e "KEYCLOAK_JGROUPS_DISCOVERY_EXTERNAL_IP=172.17.1.8" \
    --add-host galera-cluster.cygnus3.io:${DB_IP} \
        dockeregistry.amovildigitalops.com/atomic-rhel7-keycloak-9

    #-e "KEYCLOAK_JGROUPS_DISCOVERY_EXTERNAL_IP=10.23.143.8" \
    #-p 8080:8080 \
    #-p 9990:9990 \
    #-p 7600:7600 \

#2Do:
# $ jboss-cli.sh -c

#/subsystem=undertow/server=default-server/http-listener=default:write-attribute(name=proxy-address-forwarding,value=true)
#/subsystem=undertow/server=default-server/http-listener=default:write-attribute(name=redirect-socket,value=proxy-https)
#/socket-binding-group=standard-sockets/socket-binding=proxy-https:add(port=443)
#run-batch
#stop-embedded-serverc