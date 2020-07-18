#!/bin/bash

#Variables
#ANALYTICS_ADMIN_USER=admin
#ANALYTICS_ADMIN_PASSWORD=admin

function check_variables(){
    if [ ! -z "${ANALYTICS_ADMIN_USER}" ]; then
        sed -i "s/ANALYTICS_ADMIN_USER=admin/ANALYTICS_ADMIN_USER=${ANALYTICS_ADMIN_USER}/g" /opt/ibm/wlp/usr/servers/mfp/server.env
    else
        echo "[AMX] ANALYTICS_ADMIN_USER not found"
        exit 1
    fi

    if [ ! -z "${ANALYTICS_ADMIN_PASSWORD}" ]; then
        sed -i "s/ANALYTICS_ADMIN_PASSWORD=admin/ANALYTICS_ADMIN_PASSWORD=${ANALYTICS_ADMIN_PASSWORD}/g" /opt/ibm/wlp/usr/servers/mfp/server.env
    else
        echo "[AMX] ANALYTICS_ADMIN_PASSWORD not found"
        exit 1
    fi
}

#Dependencias
mkdir -p /opt/ibm
cp /MobileFirst/dependencies/ibm-java-jre-8.0-5.17-linux-x86_64_*.tgz /opt/ibm/
tar -xvf /opt/ibm/*1.tgz -C /opt/ibm && tar -xvf /opt/ibm/*2.tgz -C /opt/ibm && rm -f /opt/ibm/*.tgz
mkdir -p /opt/ibm/docker/
cp /MobileFirst/dependencies/license-check /opt/ibm/docker/

mkdir -p /opt/ibm/MobileFirst/swidtag/
cp /MobileFirst/dependencies/ibm.com_IBM_MobileFirst_Platform_Foundation-8.0.0.swidtag /opt/ibm/MobileFirst/swidtag/

# Install WebSphere Liberty
cp /MobileFirst/dependencies/wlp-base-embeddable-18.0.0.2_*.tar.gz /opt/ibm/
tar -xvf /opt/ibm/*1.tar.gz -C /opt/ibm && tar -xvf /opt/ibm/*2.tar.gz -C /opt/ibm && rm -f /opt/ibm/*.tar.gz

#Creación del servidor
/opt/ibm/wlp/bin/server create mfp
rm -rf /opt/ibm/wlp/usr/servers/.classCache && rm -rf /opt/ibm/wlp/usr/servers/mfp/apps/*

tar -xvf /MobileFirst/mfpf-libs/mfpf-analytics.tgz -C /
cp -r /MobileFirst/licenses /opt/ibm/MobileFirst/licenses

chmod u+x /opt/ibm/docker/license-check
chmod u+x /opt/ibm/wlp/bin/liberty-run

#Configuración del server
cp /MobileFirst/mfpf-analytics/usr/bin/mfp-init /opt/ibm/wlp/bin/
chmod u+x /opt/ibm/wlp/bin/mfp-init
mkdir -p /opt/ibm/wlp/usr/servers/mfp/resources/security/
cp -r /MobileFirst/mfpf-analytics/usr/security/* /opt/ibm/wlp/usr/servers/mfp/resources/security/
cp -r /MobileFirst/mfpf-analytics/usr/jre-security/* /opt/ibm/ibm-java-x86_64-80/jre/lib/security/
cp -r /MobileFirst/mfpf-analytics/usr/env/* /opt/ibm/wlp/usr/servers/mfp/
cp -r /MobileFirst/mfpf-analytics/usr/ssh/* /root/sshkey/
mkdir -p /opt/ibm/wlp/usr/servers/mfp/configDropins/overrides/
cp -r /MobileFirst/mfpf-analytics/usr/config/*.xml /opt/ibm/wlp/usr/servers/mfp/configDropins/overrides/

#Verificar variables
check_variables
echo $ANALYTICS_ADMIN_USER
echo $ANALYTICS_ADMIN_PASSWORD

#Prender servidor
#while :; do cd /opt/ibm/wlp/bin/ && ./server start mfp; sleep 20; done
cd /opt/ibm/wlp/bin/ && ./server start mfp

function docker_stop {
    export STOP_PROC=1;
}

EXIT_DAEMON=0
STOP_PROC=0

while [ $EXIT_DAEMON -eq 0 ]; do
    if [ $STOP_PROC != 0 ]
    then
        echo "Starting the Server"
        cd /opt/ibm/wlp/bin/ && ./server start mfp
        break;
    fi
    sleep 5
done