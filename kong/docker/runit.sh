#!/bin/bash

# Mauricio Melendez & Kevin Gómez | AMX GADT

KONG_CONTAINER=kong

docker run -itd --name $KONG_CONTAINER \
    --hostname=$KONG_CONTAINER.service \
    --health-cmd='/sbin/docker-health-check.sh' \
    --health-interval=10s \
    --restart unless-stopped \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -e "TZ=America/Mexico_City" \
    -e "KONG_CASSANDRA_CONTACT_POINTS=kong-database" \
    -e "KONG_CASSANDRA_KEYSPACE=kong" \
    -e "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl" \
    -e "KONG_CASSANDRA_USERNAME=admin" \
    -e "KONG_CASSANDRA_PASSWORD=abcd1234" \
    -p 8001:8001 \
    -p 8444:8444 \
    --add-host kong-database:10.23.143.7 \
    dockeregistry.amovildigitalops.com/atomic-rhel7-kong:1.4.2