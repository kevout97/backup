#!/bin/bash

# Created by Mauricio & Kevs | AMX GADT

export LD_LIBRARY_PATH=/opt/rh/devtoolset-3/root/usr/lib64/
FIRST_RUN=1
MAIN_PROC_RUN=1

trap "docker_stop" SIGINT SIGTERM

function docker_stop {
    echo "[AMX $(date +'%Y-%m-%d %R')] Rcv end signal"
    OPENDKIM_PID=$(pgrep opendkim)
    kill -9 $OPENDKIM_PID
    export MAIN_PROC_RUN=0
}

function check_variables {
    if [ -n "${OPENDKIM_DOMAIN}" ]; then
        if [ ! -f /etc/opendkim/keys/$OPENDKIM_DOMAIN/default.txt ]; then
            mkdir -p /etc/opendkim/keys/$OPENDKIM_DOMAIN
            cd /etc/opendkim/keys/$OPENDKIM_DOMAIN
            opendkim-genkey -r -d $OPENDKIM_DOMAIN
            echo "default._domainkey.$OPENDKIM_DOMAIN $OPENDKIM_DOMAIN:default:/etc/opendkim/keys/$OPENDKIM_DOMAIN/default.private" >> /etc/opendkim/KeyTable
            echo "*@$OPENDKIM_DOMAIN default._domainkey.$OPENDKIM_DOMAIN" >> /etc/opendkim/SigningTable
            echo "mail.$OPENDKIM_DOMAIN" >> /etc/opendkim/TrustedHosts
            echo "$OPENDKIM_DOMAIN" >> /etc/opendkim/TrustedHosts
            chown -R opendkim:opendkim /etc/opendkim
            chmod go-rw /etc/opendkim/keys
        fi
    else
        echo "[AMX $(date +'%Y-%m-%d %R')] OPENDKIM_DOMAIN not found"
        exit 1
    fi
}

echo "[AMX $(date +'%Y-%m-%d %R')] Configuring dkim for $OPENDKIM_DOMAIN..."
check_variables
echo "[AMX $(date +'%Y-%m-%d %R')] Configuration was successful"
echo "[AMX $(date +'%Y-%m-%d %R')] Put this on your file dns zone, without brackets"
echo "#########################################"
echo "\$ORIGIN $OPENDKIM_DOMAIN"
cat /etc/opendkim/keys/$OPENDKIM_DOMAIN/default.txt
echo "#########################################"
echo ""
echo "[AMX $(date +'%Y-%m-%d %R')] Add these lines at the end on your main.cf of your postfix service"
echo "#########################################"
echo 'smtpd_milters = inet:0.0.0.0:8891'
echo 'non_smtpd_milters = $smtpd_milters'
echo 'milter_default_action = accept'
echo "#########################################"
echo ""
echo "[AMX $(date +'%Y-%m-%d %R')] Starting Opendkim..."
while [ ${MAIN_PROC_RUN} -eq 1 ]; do
    if [ "${FIRST_RUN}" -ne 0 ] ; then
        /usr/sbin/opendkim -x /etc/opendkim.conf -P /var/run/opendkim/opendkim.pid -u opendkim
        echo "[AMX $(date +'%Y-%m-%d %R')] Started Opendkim"
    fi
    sleep 5
    /sbin/docker-health-check.sh
    FIRST_RUN=$?
done