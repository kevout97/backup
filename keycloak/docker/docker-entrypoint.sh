#!/bin/bash

# Mauricio Melendez & Kevin Gómez | AMX GA/DT

env > /tmp/.env

FIRST_RUN=1
MAIN_PID=$$
MAIN_PROC_RUN=1
ADD_ADMIN_USER=""
ADD_ADMIN_USER_WIDFLY=""
START_WFLY_COMMAND="${BASE_DIRECTORY}/bin/standalone.sh --server-config=standalone-ha.xml"
FILE_CONFIG=${BASE_DIRECTORY}/standalone/configuration/standalone-ha.xml
mkdir -p $BASE_DIRECTORY/keycloak-imports

trap "docker_stop" SIGINT SIGTERM

function docker_stop {
    echo "[AMX] $(date) Rcv end signal"
    $BASE_DIRECTORY/bin/jboss-cli.sh --connect command=:shutdown
    export MAIN_PROC_RUN=0
}

function check_variables(){
    # Variables para todos los tipos de despliegue
    HOSTNAME=$(cat /proc/sys/kernel/hostname)
    LISTEN_ADDRESS=$(awk "/${HOSTNAME}/{print \$1}" /etc/hosts)

    START_WFLY_COMMAND="$START_WFLY_COMMAND -bjboss.bind.address.private $LISTEN_ADDRESS"
    if [ ! -z "${KEYCLOAK_BIN_ADDRESS_MANAGEMENT}" ]; then
        START_WFLY_COMMAND="$START_WFLY_COMMAND -bmanagement $KEYCLOAK_BIN_ADDRESS_MANAGEMENT"
    fi

    if [ ! -z "${KEYCLOAK_BIN_ADDRESS}" ]; then
        START_WFLY_COMMAND="$START_WFLY_COMMAND -b $KEYCLOAK_BIN_ADDRESS"
    fi

    if [ ! -z "${KEYCLOAK_AJP_PORT}" ]; then
        START_WFLY_COMMAND="$START_WFLY_COMMAND -Djboss.ajp.port=$KEYCLOAK_AJP_PORT"
    fi

    if [ ! -z "${KEYCLOAK_HTTP_PORT}" ]; then
        START_WFLY_COMMAND="$START_WFLY_COMMAND -Djboss.http.port=$KEYCLOAK_HTTP_PORT"
    fi

    if [ ! -z "${KEYCLOAK_HTTPS_PORT}" ]; then
        START_WFLY_COMMAND="$START_WFLY_COMMAND -Djboss.https.port=$KEYCLOAK_HTTPS_PORT"
    fi

    if [ ! -z "${KEYCLOAK_MANAGEMENT_HTTP_PORT}" ]; then
        START_WFLY_COMMAND="$START_WFLY_COMMAND -Djboss.management.http.port=$KEYCLOAK_MANAGEMENT_HTTP_PORT"
    fi

    if [ ! -z "${KEYCLOAK_IMPORT}" ]; then
        START_WFLY_COMMAND="$START_WFLY_COMMAND -Dkeycloak.import=$KEYCLOAK_IMPORT"
    fi

    if [ ! -z "${KEYCLOAK_MANAGEMENT_HTTPS_PORT}" ]; then
        START_WFLY_COMMAND="$START_WFLY_COMMAND -Djboss.management.https.port=$KEYCLOAK_MANAGEMENT_HTTPS_PORT"
    fi

    if [ ! -z "${KEYCLOAK_PROXY_HTTPS_PORT}" ]; then
        START_WFLY_COMMAND="$START_WFLY_COMMAND -Djboss.proxy.https=$KEYCLOAK_PROXY_HTTPS_PORT"
    fi

    if [ ! -z "${KEYCLOAK_JGROUPS_TCP_PORT}" ]; then
        START_WFLY_COMMAND="$START_WFLY_COMMAND -Djboss.jgroups.tcp.port=$KEYCLOAK_JGROUPS_TCP_PORT"
    fi

    if [ ! -z "${KEYCLOAK_SMTP_REMOTE_HOST}" ]; then
        if [ ! -z "${KEYCLOAK_SMTP_REMOTE_PORT}" ]; then
            sed -i "s%<remote-destination host=\".*%<remote-destination host=\"$KEYCLOAK_SMTP_REMOTE_HOST\" port=\"$KEYCLOAK_SMTP_REMOTE_PORT\"\/>%g" $FILE_CONFIG
        else
            sed -i "s%<remote-destination host=\".*%<remote-destination host=\"$KEYCLOAK_SMTP_REMOTE_HOST\" port=\"25\"\/>%g" $FILE_CONFIG
        fi
    fi

    ## Conexion con la base de datos
    CONFIG_DATABASE=""
    if [ ! -z "${KEYCLOAK_MYSQL_HOST}" ]; then
        CONFIG_DATABASE="jdbc:mysql://$KEYCLOAK_MYSQL_HOST"
    else
        CONFIG_DATABASE="jdbc:mysql://localhost"
    fi

    if [ ! -z "${KEYCLOAK_MYSQL_PORT}" ]; then
        CONFIG_DATABASE="$CONFIG_DATABASE:$KEYCLOAK_MYSQL_PORT"
    else
        CONFIG_DATABASE="$CONFIG_DATABASE:3306"
    fi

    if [ ! -z "${KEYCLOAK_MYSQL_DATABASE}" ]; then
        CONFIG_DATABASE="$CONFIG_DATABASE/$KEYCLOAK_MYSQL_DATABASE?useSSL=false\&amp\;characterEncoding=UTF-8"
    else
        CONFIG_DATABASE="$CONFIG_DATABASE/keycloak?useSSL=false\&amp\;characterEncoding=UTF-8"
    fi

    sed -i "s%<connection-url>jdbc:mysql.*</connection-url>$%<connection-url>$CONFIG_DATABASE</connection-url>%g" $FILE_CONFIG

    if [ ! -z "${KEYCLOAK_MYSQL_USER}" ]; then
        sed -i "s%<user-name>.*%<user-name>$KEYCLOAK_MYSQL_USER</user-name>%g" $FILE_CONFIG
    else
        echo "[AMX] $(date) KEYCLOAK_MYSQL_USER not found."
        exit 2
    fi

    if [ ! -z "${KEYCLOAK_MYSQL_PASSWORD}" ]; then
        sed -i "s%<password>.*%<password>$KEYCLOAK_MYSQL_PASSWORD</password>%g" $FILE_CONFIG
    else
        echo "[AMX] $(date) KEYCLOAK_MYSQL_PASSWORD not found."
        exit 2
    fi

    # Configuracion HA

    if [ -n "${KEYCLOAK_CLUSTER_NAME}" ]; then
        sed -i "s%<channel name=\"ee\" stack=\"tcp\".*%<channel name=\"ee\" stack=\"tcp\" cluster=\"$KEYCLOAK_CLUSTER_NAME\"/>%g" $FILE_CONFIG
    fi
}
if [ ! -z "${KEYCLOAK_ADMIN_USER}" ]; then
    if [ ! -z "${KEYCLOAK_ADMIN_PASSWORD}" ]; then
        ADD_ADMIN_USER="$BASE_DIRECTORY/bin/add-user-keycloak.sh -r master -u $KEYCLOAK_ADMIN_USER -p $KEYCLOAK_ADMIN_PASSWORD"
        ADD_ADMIN_USER_WIDFLY="$BASE_DIRECTORY/bin/add-user.sh -u $KEYCLOAK_ADMIN_USER -p $KEYCLOAK_ADMIN_PASSWORD"
    else
        echo "[AMX] $(date) KEYCLOAK_ADMIN_PASSWORD not found"
        exit 1
    fi
else
    echo "[AMX] $(date) KEYCLOAK_ADMIN_USER not found"
    exit 1
fi

echo "[AMX] $(date) Create Admin User"
$ADD_ADMIN_USER
$ADD_ADMIN_USER_WIDFLY

while [ ${MAIN_PROC_RUN} -eq 1 ]; do
    if [ "${FIRST_RUN}" -ne 0 ] ; then
        FIRST_RUN=0
        echo "[AMX] $(date) Starting Keycloak"
        check_variables
        $START_WFLY_COMMAND
    fi
    /sbin/docker-health-check.sh
    FIRST_RUN=$?
done
