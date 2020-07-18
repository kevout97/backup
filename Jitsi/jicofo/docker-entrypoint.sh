#!/bin/bash

FIRST_RUN=1
MAIN_PROC_RUN=1

JICOFO_CONFIG="/etc/jitsi/jicofo/config"

if [ -z "${JICOFO_HOST}" ]; then
    JICOFO_HOST=localhost
fi

if [ -z "${JICOFO_HOSTNAME}" ]; then
    JICOFO_HOSTNAME=claroconnect.com
fi

if [ -z "${JICOFO_SECRET}" ]; then
    JICOFO_SECRET=xP6fgU#l
fi

if [ -z "${JICOFO_PORT}" ]; then
    JICOFO_PORT=5347
fi

if [ -z "${JICOFO_AUTH_DOMAIN}" ]; then
    JICOFO_AUTH_DOMAIN=auth.claroconnect.com
fi

if [ -z "${JICOFO_AUTH_USER}" ]; then
    JICOFO_AUTH_USER="focus"
fi

if [ -z "${JICOFO_AUTH_PASSWORD}" ]; then
    JICOFO_AUTH_PASSWORD=fa8DmGQk
fi

if [ -z "${JAVA_SYS_PROPS}" ]; then
    export JAVA_SYS_PROPS="-Dnet.java.sip.communicator.SC_HOME_DIR_LOCATION=/etc/jitsi -Dnet.java.sip.communicator.SC_HOME_DIR_NAME=jicofo -Dnet.java.sip.communicator.SC_LOG_DIR_LOCATION=/var/log/jitsi -Djava.util.logging.config.file=/etc/jitsi/jicofo/logging.properties"
fi

if [ -z "${JICOFO_BRIDGE_MUC}" ]; then
    JICOFO_BRIDGE_MUC="JvbBrewery@internal.auth.claroconnect.com"
fi

sed -i "s%JICOFO_HOST=.*%JICOFO_HOST=$JICOFO_HOST%g" $JICOFO_CONFIG
sed -i "s%JICOFO_HOSTNAME=.*%JICOFO_HOSTNAME=$JICOFO_HOSTNAME%g" $JICOFO_CONFIG
sed -i "s%JICOFO_SECRET=.*%JICOFO_SECRET=$JICOFO_SECRET%g" $JICOFO_CONFIG
sed -i "s%JICOFO_PORT=.*%JICOFO_PORT=$JICOFO_PORT%g" $JICOFO_CONFIG
sed -i "s%JICOFO_AUTH_DOMAIN=.*%JICOFO_AUTH_DOMAIN=$JICOFO_AUTH_DOMAIN%g" $JICOFO_CONFIG
sed -i "s%JICOFO_AUTH_USER=.*%JICOFO_AUTH_USER=$JICOFO_AUTH_USER%g" $JICOFO_CONFIG
sed -i "s%JICOFO_AUTH_PASSWORD=.*%JICOFO_AUTH_PASSWORD=$JICOFO_AUTH_PASSWORD%g" $JICOFO_CONFIG
sed -i "s%JICOFO_OPTS=.*%JICOFO_OPTS=$JICOFO_OPTS%g" $JICOFO_CONFIG
sed -i "s%JAVA_SYS_PROPS=.*%JAVA_SYS_PROPS=\"$JAVA_SYS_PROPS\"%g" $JICOFO_CONFIG
sed -i "s%org.jitsi.jicofo.BRIDGE_MUC=.*%org.jitsi.jicofo.BRIDGE_MUC=$JICOFO_BRIDGE_MUC%g" /etc/jitsi/jicofo/sip-communicator.properties

export JAVA_SYS_PROPS=$JAVA_SYS_PROPS

while [ ${MAIN_PROC_RUN} -eq 1 ]; do
    if [ "${FIRST_RUN}" -eq 1 ] ; then
        FIRST_RUN=0
        /opt/jicofo/jicofo-1.1-SNAPSHOT/jicofo.sh --host=$JICOFO_HOST --domain=$JICOFO_HOSTNAME --port=$JICOFO_PORT --secret=$JICOFO_SECRET --user_domain=$JICOFO_AUTH_DOMAIN --user_name=$JICOFO_AUTH_USER --user_password=$JICOFO_AUTH_PASSWORD
    fi
    sleep 15
done
