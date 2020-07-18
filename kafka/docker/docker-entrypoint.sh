#!/bin/bash

# Created by Mauricio & Kevs | AMX GADT

export LD_LIBRARY_PATH=/opt/rh/devtoolset-3/root/usr/lib64/
FIRST_RUN=0
MAIN_PID=$$
MAIN_PROC_RUN=1

env > /tmp/.env

trap "docker_stop" SIGINT SIGTERM

function docker_stop {
    echo "[AMX] Rcv end signal"
    kafka-server-stop.sh
    export MAIN_PROC_RUN=0
}

function check_variables(){
    KAFKA_VARIABLES=$(env | grep KAFKA_)
    echo "" > "${KAFKA_DIR}/config/server.properties"
    for KAFKA_VAR in $KAFKA_VARIABLES; do
        VAR=$(echo "${KAFKA_VAR,,}" | awk '{split($0,a,"="); print a[1]}' | sed "s%kafka_%%g" | sed "s%\_%\.%g")
        VALUE=$(echo "$KAFKA_VAR" | awk '{split($0,a,"="); print a[2]}')
        VERIFY_VARIABLE=$(cat /opt/kafka-files/server.properties | grep $VAR | awk '{split($0,a,"="); print a[1]}')
        if [ -n "${VERIFY_VARIABLE}" ]; then
            echo "$VAR=$VALUE" >> "${KAFKA_DIR}/config/server.properties"
        else
            echo "[AMX] $(date) Variable $VAR isn't valid"
        fi
    done
}

echo "[AMX] $(date) Configuring Kafka"
check_variables

echo "[AMX] $(date) Starting Kafka"
while [ ${MAIN_PROC_RUN} -eq 1 ]; do
    if [ "${FIRST_RUN}" -eq 0 ] ; then
        FIRST_RUN=1
        kafka-server-start.sh /opt/kafka_2.12-$KAFKA_VERSION/config/server.properties
        echo "[AMX] $(date) Started Kafka"
    fi
done
