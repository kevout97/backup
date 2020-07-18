#!/bin/bash

KAFKA_CONTAINER=kafka
KAFKA_VERSION=2.3.0

rm -rf /var/containers/$KAFKA_CONTAINER/opt/kafka_2.12-$KAFKA_VERSION/logs
mkdir -p /var/containers/$KAFKA_CONTAINER/opt/kafka_2.12-$KAFKA_VERSION/logs
chown 9092:0 /var/containers/$KAFKA_CONTAINER/opt/kafka_2.12-$KAFKA_VERSION/logs

docker rm -f $KAFKA_CONTAINER

docker run -d --name $KAFKA_CONTAINER \
    --health-cmd='/sbin/docker-health-check.sh' \
    --health-interval=10s \
    --restart unless-stopped \
    -v /var/containers/$KAFKA_CONTAINER/opt/kafka_2.12-$KAFKA_VERSION/logs:/opt/kafka_2.12-$KAFKA_VERSION/logs:z \
    -p 9092:9092 \
    -e "KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181" \
    -e "KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://10.23.142.134:9092" \
    --hostname $KAFKA_CONTAINER \
    --add-host zookeeper:172.17.0.14 \
    dockeregistry.amovildigitalops.com/rhel7-atomic-kafka:2.0.3