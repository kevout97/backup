#!/bin/bash
##################################################
#                                                #
#               Runit Kafka 1.1                  #
#                                                #
##################################################

KAFKA_CONTAINER="kafka-debezium"
KAFKA_BROKER_ID="1"
KAFKA_HEAP_OPTS="-Xmx512m -Xms512m"
KAFKA_ZOOKEEPER_CONNECT="10.23.144.138:2181"
KAFKA_ADVERTISED_HOST_NAME="10.23.144.138"

mkdir -p /var/containers/$KAFKA_CONTAINER/{kafka/data,kafka/logs}
chown 1001:0 -R /var/containers/$KAFKA_CONTAINER/

docker run -itd --name $KAFKA_CONTAINER \
    --restart always \
    -h $KAFKA_CONTAINER \
    -p 9092:9092 \
    -v /var/containers/$KAFKA_CONTAINER/kafka/data:/kafka/data:z \
    -v /var/containers/$KAFKA_CONTAINER/kafka/logs:/kafka/logs:z \
    -v /etc/localtime:/etc/localtime:ro \
    -e "TZ=America/Mexico_City" \
    -e "BROKER_ID=$KAFKA_BROKER_ID" \
    -e "HOST_NAME=$KAFKA_CONTAINER" \
    -e "ADVERTISED_HOST_NAME=$KAFKA_ADVERTISED_HOST_NAME" \
    -e "ZOOKEEPER_CONNECT=$KAFKA_ZOOKEEPER_CONNECT" \
    -e "HEAP_OPTS=$KAFKA_HEAP_OPTS" \
    debezium/kafka:1.1