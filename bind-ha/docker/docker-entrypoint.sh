#!/bin/bash

# Created by Mauricio & Kev's | AMX GADT
export LD_LIBRARY_PATH=/opt/rh/devtoolset-3/root/usr/lib64/
FIRST_RUN=1
MAIN_PROC_RUN=1
BIND_CONFIG_FILE="/etc/named/named.conf"

trap "docker_stop" SIGINT SIGTERM

function docker_stop {
    echo "[AMX $(date +'%Y-%m-%d %R')] Rcv end signal"
    BIND_PID=$(pgrep named)
    rndc stop > /dev/null 2>&1 || kill -TERM $BIND_PID
    export MAIN_PROC_RUN=0
}

function check_variables(){
    env | grep BIND_ | while read BIND_VAR; do
        
        VAR=$(echo "${BIND_VAR,,}" | awk '{split($0,a,"="); print a[1]}' | sed "s%bind_%%g" | sed "s%_%-%g")
        VALUE=$(echo "$BIND_VAR" | awk '{split($0,a,"="); print a[2]}')
        VERIFY_VARIABLE=$(cat $BIND_CONFIG_FILE | grep $VAR -o | awk '{split($0,a,"="); print a[1]}')
        
        if [ "${VERIFY_VARIABLE}" != "listen-on" ] && [ "${VERIFY_VARIABLE}" != "pid-file" ] && [ "${VAR}" != "forward" ]; then
            if [ "${VERIFY_VARIABLE}" == "allow-query" ] || [ "${VERIFY_VARIABLE}" == "forwarders" ]; then
                sed -i "s%$VAR.*%$VAR\t\t\t\t{$VALUE};%g" $BIND_CONFIG_FILE
            elif [ -n "${VERIFY_VARIABLE}" ]; then
                sed -i "s%$VAR.*%$VAR\t\t\t\t$VALUE;%g" $BIND_CONFIG_FILE
            else
                echo "[AMX $(date +'%Y-%m-%d %R')] Variable $VAR isn't valid"
            fi
        elif [ "${VAR}" == "forward" ]; then
            sed -i "s%$VAR.*%$VAR\t\t\t\t$VALUE;%g" $BIND_CONFIG_FILE
        fi
    done

    if [ ! -f "/var/named/views/views.conf" ]; then
        touch /var/named/views/views.conf
    fi
    
    if [ -z "${BIND_KEY_ALGORITHM}" ]; then
        BIND_KEY_ALGORITHM="hmac-md5"
    fi

    if [ -z "${BIND_CPU}" ]; then
        BIND_CPU=1
    fi

    # Esto solo sucede la primera vez
    HOSTNAME=$(cat /etc/hostname | awk -F. '{print $1}')
    KEY_FILE=$(dnssec-keygen -a ${BIND_KEY_ALGORITHM} -b 512 -n HOST ${HOSTNAME})
    PRIV_KEY=$(cat ${KEY_FILE}.private | awk '/Key/{print $2}')
    sed -i /etc/rndc.key -e "s/key-name/${HOSTNAME}/" -e "s/key-algorithm/${BIND_KEY_ALGORITHM}/" -e "s#key-value#${PRIV_KEY}#"
}

# Check if named.conf exists

if [ ! -f /etc/named/named.conf ]; then
    mkdir -p /etc/named/
    cp /etc/named.conf /etc/named/named.conf
fi

check_variables
echo "[AMX $(date +'%Y-%m-%d %R')] Starting Bind"
while [ ${MAIN_PROC_RUN} -eq 1 ]; do
    if [ "${FIRST_RUN}" -ne 0 ] ; then
        /usr/sbin/named -4 -u named -c $BIND_CONFIG_FILE -d 0 -g -n $BIND_CPU
    fi
    /sbin/docker-health-check.sh
    FIRST_RUN=$?
done
