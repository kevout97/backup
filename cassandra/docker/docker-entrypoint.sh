#!/bin/bash

# Mauricion & Kevs | AMX GADT

CASSANDRA_CONF_DIR="/etc/cassandra/conf"
CASSANDRA_CONF_FILE="${CASSANDRA_CONF_DIR}/cassandra.yaml"

HOSTNAME=$(cat /proc/sys/kernel/hostname)
SEEDS=$(awk "/${HOSTNAME}/{print \$1}" /etc/hosts)
LISTEN_ADDRESS=$(awk "/${HOSTNAME}/{print \$1}" /etc/hosts)
CASSANDRA_LOG_LEVEL="WARN"
CONTAINER_INTERFACE=$(ls /sys/class/net/ | grep -v lo)

FIRST_RUN=1
MAIN_PID=$$
MAIN_PROC_RUN=1

env > /tmp/.env

trap "docker_stop" SIGINT SIGTERM

function docker_stop {
    echo "[AMX] Rcv end signal"
    kill -9 $(cat $CASSANDRA_FILE_PID)
    export MAIN_PROC_RUN=0
}

function check_variables(){
    sed -i ${CASSANDRA_CONF_DIR}/logback.xml -e "s/root level=\".*\"/root level=\"${CASSANDRA_LOG_LEVEL}\"/" -e "s#<level>.*</level>#<level>${CASSANDRA_LOG_LEVEL}</level>#"

    sed -i ${CASSANDRA_CONF_FILE} \
        -e "s/^listen_address.*/listen_address: ${LISTEN_ADDRESS}/" \
        -e "s/ seeds: .*/ seeds\: \"${SEEDS}\"/" \
        -e "s/^rpc_address: .*/rpc_address: \"${LISTEN_ADDRESS}\"/"
    
    env | grep "CASSANDRA_" | while read CASSANDRA_VAR; do
        VAR=$(echo "${CASSANDRA_VAR,,}" | awk '{split($0,a,"="); print a[1]}' | sed "s%cassandra_%%g")
        VALUE=$(echo "$CASSANDRA_VAR" | awk '{split($0,a,"="); print a[2]}')
        VERIFY_VARIABLE=$(cat "${CASSANDRA_CONF_FILE}" | grep $VAR | awk '{split($0,a,":"); print a[1]}')
	if [ -n "${VERIFY_VARIABLE}" ]; then
            sed -i "s%$VAR.*%$VAR: $VALUE%g" $CASSANDRA_CONF_FILE
	else
            echo "[AMX] $(date) Not recognized var: ${VAR}"
        fi
    done

    if [ -n "${DATA_CENTER}" ]; then
        sed -i "s%dc.*%dc=$DATA_CENTER%g" $CASSANDRA_CONF_FILE/cassandra-rackdc.properties
    fi

    if [ -n "${RACK}" ]; then
        sed -i "s%rc.*%rc=$RACK%g" $CASSANDRA_CONF_FILE/cassandra-rackdc.properties
    fi
}

echo "[AMX] $(date) Configuring Cassandra"
check_variables

echo "[AMX] $(date) Starting Cassandra"
while [ ${MAIN_PROC_RUN} -eq 1 ]; do
    if [ "${FIRST_RUN}" -eq 1 ] ; then
        FIRST_RUN=0
        cassandra -p $CASSANDRA_FILE_PID
        sleep 60
        CASSANDRA_ROLE=$(echo "list roles;" | cqlsh $(cat /etc/hostname) -u cassandra -p cassandra | grep cassandra | awk '{print $1}')
        if [ "${CASSANDRA_ROLE}" == "cassandra" ]; then    
            echo "[AMX] $(date) Creating Admin user"
            if [ -n "${CASSANDRA_ADMIN_PASSWORD}" ]; then
                echo "CREATE ROLE admin WITH PASSWORD = '$CASSANDRA_ADMIN_PASSWORD' AND SUPERUSER = true AND LOGIN = true;" | cqlsh $(cat /etc/hostname) -u cassandra -p cassandra
                echo "drop role cassandra;" | cqlsh $(cat /etc/hostname) -u admin -p $CASSANDRA_ADMIN_PASSWORD
            else
                echo "[AMX] $(date) CASSANDRA_ADMIN_PASSWORD not found"
                exit 1
            fi
        else
            echo "[AMX] $(date) Admin account was configured by other Cassandra"
        fi
        echo "[AMX] $(date) Started Cassandra"
    fi

    /sbin/docker-health-check.sh
    FIRST_RUN=$?
    sleep 10
done