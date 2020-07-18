#!/bin/bash

# Mauricio Melendez & Kevin Gómez | AMX GA/DT

set -exo pipefail

env > /tmp/.env

export LD_LIBRARY_PATH=/opt/rh/devtoolset-3/root/usr/lib64/
FIRST_RUN=0
MAIN_PID=$$
MAIN_PROC_RUN=1
KONGA_DIRECTORY=/opt/konga
mkdir -p $KONGA_DIRECTORY
KONGA_FILE=$KONGA_DIRECTORY/.env

trap "docker_stop" SIGINT SIGTERM

function docker_stop {
    echo "[AMX] Rcv end signal"
    pkill node
    export MAIN_PROC_RUN=0
}

function check_variables(){
    if [ -n "${KONGA_HOST}" ]; then
        sed -i "s%HOST=.*%HOST=$KONGA_HOST%g" $KONGA_FILE
    fi

    if [ -n "${KONGA_PORT}" ]; then
        sed -i "s%PORT=.*%PORT=$KONGA_PORT%g" $KONGA_FILE
    fi

    if [ -n "${KONGA_NODE_ENV}" ]; then
        sed -i "s%NODE_ENV=.*%NODE_ENV=$KONGA_NODE_ENV%g" $KONGA_FILE
    fi

    if [ -n "${KONGA_SSL_KEY_PATH}" ]; then
        sed -i "s%SSL_KEY_PATH=.*%SSL_KEY_PATH=$KONGA_SSL_KEY_PATH%g" $KONGA_FILE
    fi

    if [ -n "${KONGA_SSL_CRT_PATH}" ]; then
        sed -i "s%SSL_CRT_PATH=.*%SSL_CRT_PATH=$KONGA_SSL_CRT_PATH%g" $KONGA_FILE
    fi

    if [ -n "${KONGA_KONGA_HOOK_TIMEOUT}" ]; then
        sed -i "s%KONGA_HOOK_TIMEOUT=.*%KONGA_HOOK_TIMEOUT=$KONGA_KONGA_HOOK_TIMEOUT%g" $KONGA_FILE
    fi

    if [ -n "${KONGA_DB_USER}" ]; then
        sed -i "s%DB_USER=.*%DB_USER=$KONGA_DB_USER%g" $KONGA_FILE
    fi

    if [ -n "${KONGA_DB_PASSWORD}" ]; then
        sed -i "s%DB_PASSWORD=.*%DB_PASSWORD=$KONGA_DB_PASSWORD%g" $KONGA_FILE
    fi

    if [ -n "${KONGA_DB_HOST}" ]; then
        sed -i "s%DB_HOST=.*%DB_HOST=$KONGA_DB_HOST%g" $KONGA_FILE
    fi

    if [ -n "${KONGA_DB_PORT}" ]; then
        sed -i "s%DB_PORT=.*%DB_PORT=$KONGA_DB_PORT%g" $KONGA_FILE
    fi

    if [ -n "${KONGA_DB_DATABASE}" ]; then
        sed -i "s%DB_DATABASE=.*%DB_DATABASE=$KONGA_DB_DATABASE%g" $KONGA_FILE
    fi

    if [ -n "${KONGA_DB_PG_SCHEMA}" ]; then
        sed -i "s%DB_PG_SCHEMA=.*%DB_PG_SCHEMA=$KONGA_DB_PG_SCHEMA%g" $KONGA_FILE
    fi

    if [ -n "${KONGA_KONGA_LOG_LEVEL}" ]; then
        sed -i "s%KONGA_LOG_LEVEL=.*%KONGA_LOG_LEVEL=$KONGA_KONGA_LOG_LEVEL%g" $KONGA_FILE
    fi

    if [ -n "${KONGA_TOKEN_SECRET}" ]; then
        sed -i "s%TOKEN_SECRET=.*%TOKEN_SECRET=$KONGA_TOKEN_SECRET%g" $KONGA_FILE
        sed -i "s/secret:.*/secret: '$KONGA_TOKEN_SECRET'/g" $KONGA_DIRECTORY/config/session.js
    fi

    if [ -n "${KONGA_NO_AUTH}" ]; then
        sed -i "s%NO_AUTH=.*%NO_AUTH=$KONGA_NO_AUTH%g" $KONGA_FILE
    fi

    if [ -n "${KONGA_BASE_URL}" ]; then
        sed -i "s%BASE_URL=.*%KONGA_BASE_URL=$KONGA_BASE_URL%g" $KONGA_FILE
    fi

    if [ -n "${KONGA_KONGA_SEED_USER_DATA_SOURCE_FILE}" ]; then
        sed -i "s%KONGA_SEED_USER_DATA_SOURCE_FILE=.*%KONGA_SEED_USER_DATA_SOURCE_FILE=$KONGA_KONGA_SEED_USER_DATA_SOURCE_FILE%g" $KONGA_FILE
    fi

    if [ -n "${KONGA_KONGA_SEED_KONG_NODE_DATA_SOURCE_FILE}" ]; then
        sed -i "s%KONGA_SEED_KONG_NODE_DATA_SOURCE_FILE=.*%KONGA_SEED_KONG_NODE_DATA_SOURCE_FILE=$KONGA_KONGA_SEED_KONG_NODE_DATA_SOURCE_FILE%g" $KONGA_FILE
    fi

    if [ -n "${KONGA_DB_ADAPTER}" ]; then
        sed -i "s%DB_ADAPTER=.*%DB_ADAPTER=$KONGA_DB_ADAPTER%g" $KONGA_FILE
        echo "[AMX] Preparing Konga's database"
        if [ -n "${KONGA_DB_URI}" ]; then
            sed -i "s%DB_URI=.*%DB_URI=$KONGA_DB_URI%g" $KONGA_FILE
        else
            echo "[AMX] KONGA_DB_URI not found"
            exit 1
        fi
        node $KONGA_DIRECTORY/bin/konga.js  prepare --adapter $KONGA_DB_ADAPTER --uri $KONGA_DB_URI
    fi
}

if [ -z "$(ls -A $KONGA_DIRECTORY)" ]; then
    echo "[AMX] Directory is empty"
    echo "[AMX] Configuring Konga's directory"
    git clone https://github.com/pantsel/konga.git $KONGA_DIRECTORY
    echo "[AMX] Installing Konga"
    cd $KONGA_DIRECTORY
    npm install -g bower sails-mysql sails gulp && bower --allow-root install && npm run bower-deps && npm --unsafe-perm --production install && npm audit fix
else
    echo "[AMX] Directory isn't empty"
    echo "[AMX] Installing Konga"
    cd $KONGA_DIRECTORY
    npm install -g bower sails-mysql sails gulp && bower --allow-root install && npm run bower-deps && npm --unsafe-perm --production install && npm audit fix
fi

if [ ! -f "$KONGA_DIRECTORY/.env" ]; then
    echo "[AMX] Creating Konga's configuration file"
    cp -f /konga-files/.env $KONGA_DIRECTORY/
fi

echo "[AMX] Configuring Konga"
check_variables

echo "[AMX] Starting Konga"
while [ ${MAIN_PROC_RUN} -eq 1 ]; do
    if [ "${FIRST_RUN}" -eq 0 ] ; then
        $KONGA_DIRECTORY/start.sh
        echo "[AMX] Started Konga"
        FIRST_RUN=1
    fi
done