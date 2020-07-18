#!/bin/bash

REDIS_CONF=/etc/redis.$REDIS_VERSION/redis.conf
FIRST_RUN=1
MAIN_PID=$$
SERVER_PID=
MAIN_PROC_RUN=1


env > /tmp/.env

trap "docker_stop" SIGINT SIGTERM

function docker_stop {
    echo "[AMX] $(date) Rcv end signal"
    kill -15 ${SERVER_PID}
    wait ${SERVER_PID}
    echo "[AMX] $(date) Redis end"
    export MAIN_PROC_RUN=0
} 


function check_variables {
    echo "" > $REDIS_CONF
    echo "bind 0.0.0.0" >> $REDIS_CONF
    echo "pidfile /var/run/redis_6379.pid" >> $REDIS_CONF
    echo "dir /var/lib/redis/" >> $REDIS_CONF

    # Configuracion Sentinel
    env | grep REDIS_SENTINEL_ | while read REDIS_VAR; do
        VAR=$(echo "${REDIS_VAR,,}" | awk '{split($0,a,"="); print a[1]}' | sed "s%redis_sentinel_%%g" | sed "s%_%-%g")
        VALUE=$(echo "$REDIS_VAR" | awk '{split($0,a,"="); print a[2]}')
        VERIFY_VARIABLE=$(cat /etc/redis.conf | grep $VAR | awk '{split($0,a,"="); print a[1]}')
        if [ -n "${VERIFY_VARIABLE}" ]; then
            IFS=';' read -ra VALUE_SENTINEL <<< "$VALUE"
            for VALUE_SENTINEL_TMP in "${VALUE_SENTINEL[@]}"; do
                echo "sentinel $VAR $VALUE_SENTINEL_TMP" >> $REDIS_CONF
            done
        else
            echo "[AMX] $(date) Variable $VAR isn't valid"
        fi
    done

    # Configuracion Redis
    env | grep REDIS_ | grep -v REDIS_SENTINEL_ | while read REDIS_VAR; do
        VAR=$(echo "${REDIS_VAR,,}" | awk '{split($0,a,"="); print a[1]}' | sed "s%redis_%%g" | sed "s%_%-%g")
        VALUE=$(echo "$REDIS_VAR" | awk '{split($0,a,"="); print a[2]}')
        VERIFY_VARIABLE=$(cat /etc/redis.conf | grep $VAR | awk '{split($0,a,"="); print a[1]}')
        if [ -n "${VERIFY_VARIABLE}" ]; then
            IFS=';' read -ra VALUE_REDIS <<< "$VALUE"
            for VALUE_REDIS_TMP in "${VALUE_REDIS[@]}"; do
                echo "$VAR $VALUE_REDIS_TMP" >> $REDIS_CONF
            done
        else
            echo "[AMX] $(date) Variable $VAR isn't valid"
        fi
    done
}

echo "[AMX] $(date) Configuring Redis"
check_variables
cat $REDIS_CONF

while [ ${MAIN_PROC_RUN} -eq 1 ]; do
    if [ "${FIRST_RUN}" -eq 1 ] ; then
        FIRST_RUN=0
        SENTINEL_INSTANCE=$(env | grep REDIS_SENTINEL_ | head -n 1)
        if [ -n "${SENTINEL_INSTANCE}" ]; then
            echo "[AMX] $(date) Deploy Sentinel Instance"
            redis-sentinel $REDIS_CONF
        else
            echo "[AMX] $(date) Start redis server"
            redis-server $REDIS_CONF --protected-mode no
        fi
    fi

    /sbin/docker-health-check.sh
    FIRST_RUN=$?
    sleep 10
done
