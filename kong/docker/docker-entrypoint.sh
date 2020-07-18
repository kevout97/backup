#!/bin/bash

# Mauricio Melendez & Kevin Gómez | AMX GA/DT

export LD_LIBRARY_PATH=/opt/rh/devtoolset-3/root/usr/lib64/
FIRST_RUN=1
MAIN_PID=$$
MAIN_PROC_RUN=1
KONG_CONFIG_FILE=/etc/kong/conf/kong.conf

if [ -z "${KONG_DIRECTORY}" ]; then
    export KONG_DIRECTORY="/usr/local/kong"
fi

env > /tmp/.env

trap "docker_stop" SIGINT SIGTERM

function docker_stop {
    echo "[AMX] $(date) Rcv end signal"
    kong stop -p $KONG_DIRECTORY
    export MAIN_PROC_RUN=0
}

function check_variables(){
    env | grep KONG_ | while read KONG_VAR; do
        VAR=$(echo "${KONG_VAR,,}" | awk '{split($0,a,"="); print a[1]}' | sed "s%kong_%%g")
        VALUE=$(echo "$KONG_VAR" | awk '{split($0,a,"="); print a[2]}')
        VERIFY_VARIABLE=$(cat $KONG_CONFIG_FILE | grep $VAR | awk '{split($0,a,"="); print a[1]}')
        if [ -n "${VERIFY_VARIABLE}" ]; then
            sed -i "s%$VAR.*%$VAR = $VALUE%g" $KONG_CONFIG_FILE
        else
            echo "[AMX] $(date) Variable $VAR isn't valid"
        fi
    done
}

echo "[AMX] $(date) Check environment variables"
check_variables

if [ -z "$(ls -A $KONG_DIRECTORY)" ]; then
    echo "[AMX] $(date) Directory is empty"
    echo "[AMX] $(date) Configuring Kong's Directory"
    kong prepare -c $KONG_CONFIG_FILE -p $KONG_DIRECTORY
else
    echo "[AMX] $(date) Directory isn't empty"
fi

echo "[AMX] $(date) Configuring Kong's database"
kong migrations bootstrap -c $KONG_CONFIG_FILE

echo "[AMX] $(date) Starting Kong"
while [ ${MAIN_PROC_RUN} -eq 1 ]; do
    if [ "${FIRST_RUN}" -ne 0 ] ; then
        FIRST_RUN=0
        kong start -c $KONG_CONFIG_FILE
        echo "[AMX] $(date) Started Kong"
    fi
    /sbin/docker-health-check.sh
    FIRST_RUN=$?
done