#!/bin/bash
# by: Mauricio & Kevs | Si quieres que algo salga bien hazlo bien, excepto el Mobilefirst :c

# MFPF_DB2_SERVER_NAME=
# MFPF_DB2_PORT=
# MFPF_DB2_DATABASE_NAME=
# MFPF_DB2_USERNAME=
# MFPF_DB2_PASSWORD=
# MFPF_USER=
# MFPF_USER_PASSWORD=

FIRST_RUN=0
MAIN_PID=$$
MAIN_PROC_RUN=1

env > /tmp/.env

trap "docker_stop" SIGINT SIGTERM

function docker_stop {
    echo "[AMX] Rcv end signal"
    /opt/ibm/wlp/bin/server stop mfp
    export MAIN_PROC_RUN=0
}

function check_variables_mfpf(){
    if [ ! -z "${MFPF_CLUSTER_MODE}" ]; then
        sed -i "s%MFPF_CLUSTER_MODE=.*%MFPF_CLUSTER_MODE=$MFPF_CLUSTER_MODE%g" /opt/ibm/wlp/usr/servers/mfp/server.env
    fi

    if [ "${MFPF_CLUSTER_MODE}" == "Farm" ] && [ ! -z "${MFPF_SERVER_ID}" ]; then
        sed -i "s%<jndiEntry jndiName=\"mfp.admin.serverid\" value=\".*%<jndiEntry jndiName=\"mfp.admin.serverid\" value=\"$MFPF_SERVER_ID\"\/>%g" /opt/ibm/wlp/usr/servers/mfp/server.xml
    else
        echo "[AMX] MFPF_CLUSTER_MODE is Farm but not found MFPF_SERVER_ID"
        exit 1
    fi

    if [ ! -z "${MFPF_USER}" ]; then
        sed -i "s%MFPF_ADMIN_USER=.*%MFPF_ADMIN_USER=$MFPF_USER%g" /opt/ibm/wlp/usr/servers/mfp/server.env
    else
        echo "[AMX] MFPF_USER not found"
        exit 1
    fi

    if [ ! -z "${MFPF_USER_PASSWORD}" ]; then
        sed -i "s%MFPF_ADMIN_PASSWORD=.*%MFPF_ADMIN_PASSWORD=$MFPF_USER_PASSWORD%g" /opt/ibm/wlp/usr/servers/mfp/server.env
    else
        echo "[AMX] MFPF_USER_PASSWORD not found"
        exit 1
    fi

    if [ ! -z "${MFPF_ADMIN_USER}" ]; then
        sed -i "s%MFPF_SERVER_ADMIN_USER=.*%MFPF_SERVER_ADMIN_USER=$MFPF_ADMIN_USER%g" /opt/ibm/wlp/usr/servers/mfp/server.env
    else
        echo "[AMX] MFPF_ADMIN_USER not found"
        exit 1
    fi

    if [ ! -z "${MFPF_ADMIN_USER_PASSWORD}" ]; then
        sed -i "s%MFPF_SERVER_ADMIN_PASSWORD=.*%MFPF_SERVER_ADMIN_PASSWORD=$MFPF_ADMIN_USER_PASSWORD%g" /opt/ibm/wlp/usr/servers/mfp/server.env
    else
        echo "[AMX] MFPF_ADMIN_USER_PASSWORD not found"
        exit 1
    fi

    if [ ! -z "${MFPF_DB2_SERVER_NAME}" ]; then
        sed -i "s%MFPF_ADMIN_DB2_SERVER_NAME=.*%MFPF_ADMIN_DB2_SERVER_NAME=$MFPF_DB2_SERVER_NAME%g" /opt/ibm/wlp/usr/servers/mfp/server.env
        sed -i "s%MFPF_RUNTIME_DB2_SERVER_NAME=.*%MFPF_RUNTIME_DB2_SERVER_NAME=$MFPF_DB2_SERVER_NAME%g" /opt/ibm/wlp/usr/servers/mfp/server.env
        sed -i "s%MFPF_PUSH_DB2_SERVER_NAME=.*%MFPF_PUSH_DB2_SERVER_NAME=$MFPF_DB2_SERVER_NAME%g" /opt/ibm/wlp/usr/servers/mfp/server.env
    else
        echo "[AMX] MFPF_DB2_SERVER_NAME not found"
        exit 1
    fi

    if [ ! -z "${MFPF_DB2_PORT}" ]; then
        sed -i "s%MFPF_ADMIN_DB2_PORT=.*%MFPF_ADMIN_DB2_PORT=$MFPF_DB2_PORT%g" /opt/ibm/wlp/usr/servers/mfp/server.env
        sed -i "s%MFPF_RUNTIME_DB2_PORT=.*%MFPF_RUNTIME_DB2_PORT=$MFPF_DB2_PORT%g" /opt/ibm/wlp/usr/servers/mfp/server.env
        sed -i "s%MFPF_PUSH_DB2_PORT=.*%MFPF_PUSH_DB2_PORT=$MFPF_DB2_PORT%g" /opt/ibm/wlp/usr/servers/mfp/server.env
    else
        echo "[AMX] MFPF_DB2_PORT not found"
        exit 1
    fi

    if [ ! -z "${MFPF_DB2_DATABASE_NAME}" ]; then
        sed -i "s%MFPF_ADMIN_DB2_DATABASE_NAME=.*%MFPF_ADMIN_DB2_DATABASE_NAME=$MFPF_DB2_DATABASE_NAME%g" /opt/ibm/wlp/usr/servers/mfp/server.env
        sed -i "s%MFPF_RUNTIME_DB2_DATABASE_NAME=.*%MFPF_RUNTIME_DB2_DATABASE_NAME=$MFPF_DB2_DATABASE_NAME%g" /opt/ibm/wlp/usr/servers/mfp/server.env
        sed -i "s%MFPF_PUSH_DB2_DATABASE_NAME=.*%MFPF_PUSH_DB2_DATABASE_NAME=$MFPF_DB2_DATABASE_NAME%g" /opt/ibm/wlp/usr/servers/mfp/server.env
    else
        echo "[AMX] MFPF_DB2_DATABASE_NAME not found"
        exit 1
    fi

    if [ ! -z "${MFPF_DB2_USERNAME}" ]; then
        sed -i "s%MFPF_ADMIN_DB2_USERNAME=.*%MFPF_ADMIN_DB2_USERNAME=$MFPF_DB2_USERNAME%g" /opt/ibm/wlp/usr/servers/mfp/server.env
        sed -i "s%MFPF_RUNTIME_DB2_USERNAME=.*%MFPF_RUNTIME_DB2_USERNAME=$MFPF_DB2_USERNAME%g" /opt/ibm/wlp/usr/servers/mfp/server.env
        sed -i "s%MFPF_PUSH_DB2_USERNAME=.*%MFPF_PUSH_DB2_USERNAME=$MFPF_DB2_USERNAME%g" /opt/ibm/wlp/usr/servers/mfp/server.env
    else
        echo "[AMX] MFPF_DB2_USERNAME not found"
        exit 1
    fi

    if [ ! -z "${MFPF_DB2_PASSWORD}" ]; then
        sed -i "s%MFPF_ADMIN_DB2_PASSWORD=.*%MFPF_ADMIN_DB2_PASSWORD=$MFPF_DB2_PASSWORD%g" /opt/ibm/wlp/usr/servers/mfp/server.env
        sed -i "s%MFPF_RUNTIME_DB2_PASSWORD=.*%MFPF_RUNTIME_DB2_PASSWORD=$MFPF_DB2_PASSWORD%g" /opt/ibm/wlp/usr/servers/mfp/server.env
        sed -i "s%MFPF_PUSH_DB2_PASSWORD=.*%MFPF_PUSH_DB2_PASSWORD=$MFPF_DB2_PASSWORD%g" /opt/ibm/wlp/usr/servers/mfp/server.env
    else
        echo "[AMX] MFPF_DB2_PASSWORD not found"
        exit 1
    fi

    if [ ! -z "${ANALYTICS_ADMIN_USER}" ]; then
        sed -i "s%<user name=\".*%<user name=\"$ANALYTICS_ADMIN_USER\"/>%g" /opt/ibm/wlp/usr/servers/mfp/server.xml
        sed -i "s%<user name=\".*%<user name=\"$ANALYTICS_ADMIN_USER\"/>%g" /opt/ibm/wlp/usr/servers/mfp/server.xml
        sed -i "s%<jndiEntry jndiName=\"mfp\/mfp.analytics.username\" value='\".*%<jndiEntry jndiName=\"mfp/mfp.analytics.username\" value='\"$ANALYTICS_ADMIN_USER\"'\/>%g" /opt/ibm/wlp/usr/servers/mfp/server.xml
        sed -i "s%<jndiEntry jndiName=\"imfpush\/mfp.push.analytics.user\" value='\".*%<jndiEntry jndiName=\"imfpush\/mfp.push.analytics.user\" value='\"$ANALYTICS_ADMIN_USER\"'\/>%g" /opt/ibm/wlp/usr/servers/mfp/server.xml
    else
        echo "[AMX] ANALYTICS_ADMIN_USER not found"
        exit 1
    fi

    if [ ! -z "${ANALYTICS_ADMIN_PASSWORD}" ]; then
        sed -i "s%<jndiEntry jndiName=\"mfp\/mfp.analytics.password\" value='\".*%<jndiEntry jndiName=\"mfp\/mfp.analytics.password\" value='\"$ANALYTICS_ADMIN_PASSWORD\"'\/>%g" /opt/ibm/wlp/usr/servers/mfp/server.xml
        sed -i "s%<jndiEntry jndiName=\"imfpush\/mfp.push.analytics.password\" value='\".*%<jndiEntry jndiName=\"imfpush\/mfp.push.analytics.password\" value='\"$ANALYTICS_ADMIN_PASSWORD\"'\/>%g" /opt/ibm/wlp/usr/servers/mfp/server.xml
    else
        echo "[AMX] ANALYTICS_ADMIN_PASSWORD not found"
        exit 1
    fi

    if [ ! -z "${ANALYTICS_URL}" ]; then
        sed -i "s%<jndiEntry jndiName=\"mfp\/mfp.analytics.url\" value='\".*%<jndiEntry jndiName=\"mfp\/mfp.analytics.url\" value='\"$ANALYTICS_URL\/analytics-service\"'\/>%g" /opt/ibm/wlp/usr/servers/mfp/server.xml
        sed -i "s%<jndiEntry jndiName=\"mfp\/mfp.analytics.console.url\" value='\".*%<jndiEntry jndiName=\"mfp\/mfp.analytics.url\" value='\"$ANALYTICS_URL\/analytics\/console\"'\/>%g" /opt/ibm/wlp/usr/servers/mfp/server.xml
        sed -i "s%<jndiEntry jndiName=\"imfpush\/mfp.push.analytics.endpoint\" value='\".*%<jndiEntry jndiName=\"imfpush\/mfp.push.analytics.endpoint\" value='\"$ANALYTICS_URL\/analytics-service\"'\/>%g" /opt/ibm/wlp/usr/servers/mfp/server.xml
        sed -i "s%<jndiEntry jndiName=\"mfp.analytics.console.url\" value=.*%<jndiEntry jndiName=\"mfp.analytics.console.url\" value='\"$ANALYTICS_URL\/analytics\/console\"'\/>%g" /opt/ibm/wlp/usr/servers/mfp/server.xml
        sed -i "s%<jndiEntry jndiName=\"mfp\/mfp.analytics.console.url\" value='\".*%<jndiEntry jndiName=\"mfp\/mfp.analytics.console.url\" value='\"$ANALYTICS_URL\/analytics\/console\"'\/>%g" /opt/ibm/wlp/usr/servers/mfp/server.xml
    else
        echo "[AMX] ANALYTICS_URL not found"
        exit 1
    fi

    if [ -n "${MFPF_SERVER_HTTPPORT}" ]; then
        sed -i "s%MFPF_SERVER_HTTPPORT=.*%MFPF_SERVER_HTTPPORT=$MFPF_SERVER_HTTPPORT%g" /opt/ibm/wlp/usr/servers/mfp/server.env
    fi

    if [ -n "${MFPF_SERVER_HTTPSPORT}" ]; then
        sed -i "s%MFPF_SERVER_HTTPSPORT=.*%MFPF_SERVER_HTTPSPORT=$MFPF_SERVER_HTTPSPORT%g" /opt/ibm/wlp/usr/servers/mfp/server.env
    fi

    if [ -n "${IP_ADDRESS}" ]; then
        sed -i "s%IP_ADDRESS=.*%IP_ADDRESS=$IP_ADDRESS%g" /opt/ibm/wlp/usr/servers/mfp/server.env
        sed -i "s%ADMIN_HOST=.*%ADMIN_HOST=$IP_ADDRESS%g" /opt/ibm/wlp/usr/servers/mfp/server.env
        sed -i "s%HOSTNAME=.*%HOSTNAME=$IP_ADDRESS%g" /opt/ibm/wlp/usr/servers/mfp/server.env
    else
        IP_ADDRESS=$(hostname)
        sed -i "s%IP_ADDRESS=.*%IP_ADDRESS=$IP_ADDRESS%g" /opt/ibm/wlp/usr/servers/mfp/server.env
    fi
}

mkdir -p /opt/ibm/wlp/usr/servers/{.logs/,.pid/}

if [ ! -z "$(ls -A /opt/ibm/wlp/usr/servers/mfp)" ]; then

    echo "[AMX] Directory of server isn't empy"
    echo "[AMX] Starting server"
else

    echo "[AMX] Directory is empty"
    echo "REJfVFlQRT0iREIyIgpEQjJfSE9TVD0iJHtNRlBGX0RCMl9TRVJWRVJfTkFNRX0iCkRCMl9EQVRBQkFTRT0iJHtNRlBGX0RCMl9EQVRBQkFTRV9OQU1FfSIKREIyX1BPUlQ9IiR7TUZQRl9EQjJfUE9SVH0iCkRCMl9VU0VSTkFNRT0iJHtNRlBGX0RCMl9VU0VSTkFNRX0iCkRCMl9QQVNTV09SRD0iJHtNRlBGX0RCMl9QQVNTV09SRH0iCkVOQUJMRV9QVVNIPSJZIg==" | base64 -d -w0 > /MobileFirst/mfpf-server/scripts/args/prepareserverdbs.properties

    sed -i "s%DB2_HOST=.*%DB2_HOST=$MFPF_DB2_SERVER_NAME%g" /MobileFirst/mfpf-server/scripts/args/prepareserverdbs.properties
    sed -i "s%DB2_DATABASE=.*%DB2_DATABASE=$MFPF_DB2_DATABASE_NAME%g" /MobileFirst/mfpf-server/scripts/args/prepareserverdbs.properties
    sed -i "s%DB2_PORT=.*%DB2_PORT=$MFPF_DB2_PORT%g" /MobileFirst/mfpf-server/scripts/args/prepareserverdbs.properties
    sed -i "s%DB2_USERNAME=.*%DB2_USERNAME=$MFPF_DB2_USERNAME%g" /MobileFirst/mfpf-server/scripts/args/prepareserverdbs.properties
    sed -i "s%DB2_PASSWORD=.*%DB2_PASSWORD=$MFPF_DB2_PASSWORD%g" /MobileFirst/mfpf-server/scripts/args/prepareserverdbs.properties

    /MobileFirst/mfpf-server/scripts/prepareserverdbs.sh /MobileFirst/mfpf-server/scripts/args/prepareserverdbs.properties
    echo "[AMX] Create server"
    /opt/ibm/wlp/bin/server create mfp
    rm -rf /opt/ibm/wlp/usr/servers/.classCache
    rm -rf /opt/ibm/wlp/usr/servers/mfp/apps/*
    tar -xf /MobileFirst/mfpf-libs/mfpf-server-containers.tgz -C /
    tar -xf /MobileFirst/mfpf-libs/mfpf-server-common.tgz -C /opt/ibm/
    mkdir -p /opt/ibm/wlp/usr/servers/mfp/resources/security/
    mkdir -p /opt/ibm/wlp/usr/servers/mfp/configDropins/overrides/
    cp -rf /MobileFirst/mfpf-server/usr/security/* /opt/ibm/wlp/usr/servers/mfp/resources/security/
    cp -rf /MobileFirst/mfpf-server/usr/env/* /opt/ibm/wlp/usr/servers/mfp/
    cp -rf /MobileFirst/mfpf-server/usr/config/*.xml /opt/ibm/wlp/usr/servers/mfp/configDropins/overrides/
    echo "[AMX] Set variables"

    echo "PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPCEtLSBMaWNlbnNlZCBNYXRlcmlhbHMgLSBQcm9wZXJ0eSBvZiBJQk0gNTcyNS1JNDMgKEMpIENvcHlyaWdodCBJQk0gQ29ycC4KICAyMDE1LCAyMDE1LiBBbGwgUmlnaHRzIFJlc2VydmVkLiBVUyBHb3Zlcm5tZW50IFVzZXJzIFJlc3RyaWN0ZWQgUmlnaHRzIC0KICBVc2UsIGR1cGxpY2F0aW9uIG9yIGRpc2Nsb3N1cmUgcmVzdHJpY3RlZCBieSBHU0EgQURQIFNjaGVkdWxlIENvbnRyYWN0IHdpdGgKICBJQk0gQ29ycC4gLS0+CjxzZXJ2ZXIgZGVzY3JpcHRpb249Im5ldyBzZXJ2ZXIiPgoKICAgIDwhLS0gRW5hYmxlIGZlYXR1cmVzIC0tPgogICAgPGZlYXR1cmVNYW5hZ2VyPgoKICAgICAgICA8IS0tIEJlZ2luIG9mIGZlYXR1cmVzIGFkZGVkIGJ5IElCTSBNb2JpbGVGaXJzdCA8aW5zdGFsbFB1c2g+IGFudCB0YXNrIGZvciBjb250ZXh0IHJvb3QgJy9pbWZwdXNoJy4gLS0+CiAgICAgICAgPCEtLSBUaGUgZm9sbG93aW5nIGxpbmVzIHdpbGwgYmUgcmVtb3ZlZCB3aGVuIHRoZSBhcHBsaWNhdGlvbiBpcyB1bmluc3RhbGxlZCAtLT4KICAgICAgICA8ZmVhdHVyZT5qZGJjLTQuMTwvZmVhdHVyZT4KICAgICAgICA8ZmVhdHVyZT5zZXJ2bGV0LTMuMTwvZmVhdHVyZT4KICAgICAgICA8ZmVhdHVyZT5zc2wtMS4wPC9mZWF0dXJlPgogICAgICAgIDwhLS0gRW5kIG9mIGZlYXR1cmVzIGFkZGVkIGJ5IElCTSBNb2JpbGVGaXJzdCA8aW5zdGFsbFB1c2g+IGFudCB0YXNrIGZvciBjb250ZXh0IHJvb3QgJy9pbWZwdXNoJy4gLS0+CiAgICAgICAgCiAgICAgICAgPGZlYXR1cmU+anNwLTIuMzwvZmVhdHVyZT4KICAgICAgICA8IS0tIEJlZ2luIG9mIGZlYXR1cmVzIGFkZGVkIGJ5IElCTSBNb2JpbGVGaXJzdCA8aW5zdGFsbG1vYmlsZWZpcnN0YWRtaW4+IGFudCB0YXNrIGZvciBjb250ZXh0IHJvb3QgJy9tZnBhZG1pbicuIC0tPgogICAgICAgIDwhLS0gVGhlIGZvbGxvd2luZyBsaW5lcyB3aWxsIGJlIHJlbW92ZWQgd2hlbiB0aGUgYXBwbGljYXRpb24gaXMgdW5pbnN0YWxsZWQgLS0+CiAgICAgICAgPGZlYXR1cmU+amRiYy00LjE8L2ZlYXR1cmU+CiAgICAgICAgPGZlYXR1cmU+YXBwU2VjdXJpdHktMi4wPC9mZWF0dXJlPgogICAgICAgIDxmZWF0dXJlPmxvY2FsQ29ubmVjdG9yLTEuMDwvZmVhdHVyZT4KICAgICAgICA8ZmVhdHVyZT5yZXN0Q29ubmVjdG9yLTEuMDwvZmVhdHVyZT4KICAgICAgICA8IS0tIEVuZCBvZiBmZWF0dXJlcyBhZGRlZCBieSBJQk0gTW9iaWxlRmlyc3QgPGluc3RhbGxtb2JpbGVmaXJzdGFkbWluPiBhbnQgdGFzayBmb3IgY29udGV4dCByb290ICcvbWZwYWRtaW4nLiAtLT4KICAgICAgICA8ZmVhdHVyZT51c3I6T0F1dGhUYWktOC4wPC9mZWF0dXJlPgogICAgICAgIDxmZWF0dXJlPmJlbGxzLTEuMDwvZmVhdHVyZT4KICAgIDwvZmVhdHVyZU1hbmFnZXI+CgogICAgPCEtLSBUbyBhY2Nlc3MgdGhpcyBzZXJ2ZXIgZnJvbSBhIHJlbW90ZSBjbGllbnQgYWRkIGEgaG9zdCBhdHRyaWJ1dGUgdG8gdGhlIGZvbGxvd2luZyBlbGVtZW50LCBlLmcuIGhvc3Q9IioiIC0tPgogICAgPGh0dHBFbmRwb2ludCBpZD0iZGVmYXVsdEh0dHBFbmRwb2ludCIKICAgICAgICAgICAgICAgICAgaHR0cFBvcnQ9IiR7ZW52Lk1GUEZfU0VSVkVSX0hUVFBQT1JUfSIKICAgICAgICAgICAgICAgICAgaHR0cHNQb3J0PSIke2Vudi5NRlBGX1NFUlZFUl9IVFRQU1BPUlR9IiBob3N0PSIqIiA+CgogICAgICAgIDwhLS0gT3B0aW9uIHNvUmV1c2VBZGRyIGFkZGVkIGJ5IElCTSBNb2JpbGVGaXJzdCA8aW5zdGFsbG1vYmlsZWZpcnN0YWRtaW4+IGFudCB0YXNrIGZvciBjb250ZXh0IHJvb3QgJy9tZnBhZG1pbicuIC0tPgogICAgICAgIDx0Y3BPcHRpb25zIHNvUmV1c2VBZGRyPSJ0cnVlIi8+CgogICAgPC9odHRwRW5kcG9pbnQ+CiAgICAKICAgIDxhZG1pbmlzdHJhdG9yLXJvbGU+CiAgICAgICAgPCEtLSAgICBNRlAgSk1YIFVzZXIuCiAgICAgICAgW0FkZGVkIGJ5IElCTSBNb2JpbGVGaXJzdCBQbGF0Zm9ybSBGb3VuZGF0aW9uIDxpbnN0YWxsbW9iaWxlZmlyc3RhZG1pbj4gQW50IHRhc2sgZm9yIGNvbnRleHQgcm9vdCAnL21mcGFkbWluJ10gIAogICAgICAgIC0tPgogICAgICAgIDx1c2VyPiR7ZW52Lk1GUEZfU0VSVkVSX0FETUlOX1VTRVJ9PC91c2VyPgoKICAgIDwvYWRtaW5pc3RyYXRvci1yb2xlPgogICAgPCEtLSAgICBNb2JpbGVGaXJzdCBKTkRJIHByb3BlcnR5IGZvciBKTVggY29ubmVjdGlvbi4KICAgICAgICBbQWRkZWQgYnkgSUJNIE1vYmlsZUZpcnN0IFBsYXRmb3JtIEZvdW5kYXRpb24gPGluc3RhbGxtb2JpbGVmaXJzdGFkbWluPiBBbnQgdGFzayBmb3IgY29udGV4dCByb290ICcvbWZwYWRtaW4nXSAKICAgIC0tPgogICAgPGpuZGlFbnRyeSBqbmRpTmFtZT0ibWZwLmFkbWluLmpteC5ob3N0IiB2YWx1ZT0iJHtlbnYuSVBfQUREUkVTU30iLz4KICAgIDwhLS0gICAgTW9iaWxlRmlyc3QgSk5ESSBwcm9wZXJ0eSBmb3IgSk1YIGNvbm5lY3Rpb24uCiAgICAgICAgW0FkZGVkIGJ5IElCTSBNb2JpbGVGaXJzdCBQbGF0Zm9ybSBGb3VuZGF0aW9uIDxpbnN0YWxsbW9iaWxlZmlyc3RhZG1pbj4gQW50IHRhc2sgZm9yIGNvbnRleHQgcm9vdCAnL21mcGFkbWluJ10gCiAgICAtLT4KICAgIDxqbmRpRW50cnkgam5kaU5hbWU9Im1mcC5hZG1pbi5zZXJ2ZXJpZCIgdmFsdWU9IiR7ZW52LkhPU1ROQU1FfSIvPgogICAgCiAgICA8am5kaUVudHJ5IGpuZGlOYW1lPSJtZnAuYWRtaW4uam14LnBvcnQiIHZhbHVlPSIke2Vudi5NRlBGX1NFUlZFUl9IVFRQU1BPUlR9Ii8+CiAgICA8IS0tICAgIE1vYmlsZUZpcnN0IEpOREkgcHJvcGVydHkgZm9yIEpNWCBjb25uZWN0aW9uLgogICAgICAgIFtBZGRlZCBieSBJQk0gTW9iaWxlRmlyc3QgUGxhdGZvcm0gRm91bmRhdGlvbiA8aW5zdGFsbG1vYmlsZWZpcnN0YWRtaW4+IEFudCB0YXNrIGZvciBjb250ZXh0IHJvb3QgJy9tZnBhZG1pbiddIAogICAgLS0+CiAgICA8am5kaUVudHJ5IGpuZGlOYW1lPSJtZnAuYWRtaW4uam14LnVzZXIiIHZhbHVlPSIke2Vudi5NRlBGX1NFUlZFUl9BRE1JTl9VU0VSfSIvPgogICAgPCEtLSAgICBNb2JpbGVGaXJzdCBKTkRJIHByb3BlcnR5IGZvciBKTVggY29ubmVjdGlvbi4KICAgICAgICBbQWRkZWQgYnkgSUJNIE1vYmlsZUZpcnN0IFBsYXRmb3JtIEZvdW5kYXRpb24gPGluc3RhbGxtb2JpbGVmaXJzdGFkbWluPiBBbnQgdGFzayBmb3IgY29udGV4dCByb290ICcvbWZwYWRtaW4nXSAKICAgIC0tPgogICAgPGpuZGlFbnRyeSBqbmRpTmFtZT0ibWZwLmFkbWluLmpteC5wd2QiIHZhbHVlPSIke2Vudi5NRlBGX1NFUlZFUl9BRE1JTl9QQVNTV09SRH0iLz4KICAgPCEtLSAgICBNb2JpbGVGaXJzdCBKTkRJIHByb3BlcnR5IGZvciBKTVggY29ubmVjdGlvbi4KICAgICAgICBbQWRkZWQgYnkgSUJNIE1vYmlsZUZpcnN0IFBsYXRmb3JtIEZvdW5kYXRpb24gPGluc3RhbGxtb2JpbGVmaXJzdGFkbWluPiBBbnQgdGFzayBmb3IgY29udGV4dCByb290ICcvbWZwYWRtaW4nXSAKICAgIC0tPgogICAgPGpuZGlFbnRyeSBqbmRpTmFtZT0ibWZwLnRvcG9sb2d5LnBsYXRmb3JtIiB2YWx1ZT0iTGliZXJ0eSIvPgogICAgPCEtLSAgICBNb2JpbGVGaXJzdCBKTkRJIHByb3BlcnR5IGZvciBKTVggY29ubmVjdGlvbi4KICAgICAgICBbQWRkZWQgYnkgSUJNIE1vYmlsZUZpcnN0IFBsYXRmb3JtIEZvdW5kYXRpb24gPGluc3RhbGxtb2JpbGVmaXJzdGFkbWluPiBBbnQgdGFzayBmb3IgY29udGV4dCByb290ICcvbWZwYWRtaW4nXSAKICAgIC0tPgogICAgPGpuZGlFbnRyeSBqbmRpTmFtZT0ibWZwLnRvcG9sb2d5LmNsdXN0ZXJtb2RlIiB2YWx1ZT0iJHtlbnYuTUZQRl9DTFVTVEVSX01PREV9Ii8+CiAgICA8am5kaUVudHJ5IGpuZGlOYW1lPSJtZnAuYWRtaW4ucG9sbGluZy5pbnRlcnZhbC5zZWMiIHZhbHVlPSIxMCIvPgogICAgCiAgICA8IS0tICAgIFdlYkNvbnRhaW5lciBzdGF0ZW1lbnQuCiAgICAgICAgW0FkZGVkIGJ5IElCTSBNb2JpbGVGaXJzdCBQbGF0Zm9ybSBGb3VuZGF0aW9uIDxpbnN0YWxsbW9iaWxlZmlyc3RhZG1pbj4gQW50IHRhc2sgZm9yIGNvbnRleHQgcm9vdCAnL21mcGFkbWluJ10gCiAgICAtLT4KICAgIDx3ZWJDb250YWluZXIgZGVmZXJTZXJ2bGV0TG9hZD0iZmFsc2UiLz4KCiAgICA8IS0tICAgIEV4ZWN1dG9yIHN0YXRlbWVudC4KICAgICAgICBbQWRkZWQgYnkgSUJNIE1vYmlsZUZpcnN0IFBsYXRmb3JtIEZvdW5kYXRpb24gPGluc3RhbGxtb2JpbGVmaXJzdGFkbWluPiBBbnQgdGFzayBmb3IgY29udGV4dCByb290ICcvbWZwYWRtaW4nXSAKICAgIC0tPgogICAgPGV4ZWN1dG9yIGlkPSJkZWZhdWx0IiBuYW1lPSJMYXJnZVRocmVhZFBvb2wiCiAgICAgICAgICAgICAgY29yZVRocmVhZHM9IjIwMCIgbWF4VGhyZWFkcz0iNDAwIiBrZWVwQWxpdmU9IjYwcyIKICAgICAgICAgICAgICBzdGVhbFBvbGljeT0iU1RSSUNUIiByZWplY3RlZFdvcmtQb2xpY3k9IkNBTExFUl9SVU5TIi8+CgogICAgPCEtLSBCZWdpbiBvZiBjb25maWd1cmF0aW9uIGFkZGVkIGJ5IElCTSBNb2JpbGVGaXJzdCA8aW5zdGFsbG1vYmlsZWZpcnN0YWRtaW4+IGFudCB0YXNrIGZvciBjb250ZXh0IHJvb3QgJy9tZnBhZG1pbicuIC0tPgoKICAgIDwhLS0gRGVjbGFyZSB0aGUgTW9iaWxlRmlyc3QgQWRtaW5pc3RyYXRpb24gU2VydmljZSBhcHBsaWNhdGlvbi4gLS0+CiAgICA8YXBwbGljYXRpb24gaWQ9IiR7ZW52Lk1GUEZfQURNSU5fUk9PVH0iIG5hbWU9IiR7ZW52Lk1GUEZfQURNSU5fUk9PVH0iIGxvY2F0aW9uPSJtZnAtYWRtaW4tc2VydmljZS53YXIiIHR5cGU9IndhciI+CiAgICAgICAgPGFwcGxpY2F0aW9uLWJuZD4KICAgICAgICAgICAgPHNlY3VyaXR5LXJvbGUgbmFtZT0ibWZwYWRtaW4iPgogICAgICAgICAgICAgICAgPGdyb3VwIG5hbWU9IiR7ZW52Lk1GUEZfQURNSU5fR1JPVVB9Ii8+CiAgICAgICAgICAgIDwvc2VjdXJpdHktcm9sZT4KICAgICAgICAgICAgCiAgICAgICAgICAgIDxzZWN1cml0eS1yb2xlIG5hbWU9Im1mcGRlcGxveWVyIj4KICAgICAgICAgICAgICAgIDxncm91cCBuYW1lPSIke2Vudi5NRlBGX0RFUExPWUVSX0dST1VQfSIvPgogICAgICAgICAgICA8L3NlY3VyaXR5LXJvbGU+CiAgICAgICAgICAgIAogICAgICAgICAgICA8c2VjdXJpdHktcm9sZSBuYW1lPSJtZnBtb25pdG9yIj4KICAgICAgICAgICAgICAgIDxncm91cCBuYW1lPSIke2Vudi5NRlBGX01PTklUT1JfR1JPVVB9Ii8+CiAgICAgICAgICAgIDwvc2VjdXJpdHktcm9sZT4KICAgICAgICAgICAgCiAgICAgICAgICAgIDxzZWN1cml0eS1yb2xlIG5hbWU9Im1mcG9wZXJhdG9yIj4KICAgICAgICAgICAgICAgIDxncm91cCBuYW1lPSIke2Vudi5NRlBGX09QRVJBVE9SX0dST1VQfSIvPgogICAgICAgICAgICA8L3NlY3VyaXR5LXJvbGU+CiAgICAgICAgPC9hcHBsaWNhdGlvbi1ibmQ+CgogICAgICAgIDxjbGFzc2xvYWRlciBkZWxlZ2F0aW9uPSJwYXJlbnRMYXN0Ij4KICAgICAgICAgICAgPGNvbW1vbkxpYnJhcnkgaWQ9Im1mcGxpYl9tZnBhZG1pbiI+CiAgICAgICAgICAgIAk8ZmlsZXNldCBkaXI9IiR7d2xwLmluc3RhbGwuZGlyfS9saWIiIGluY2x1ZGVzPSJjb20uaWJtLndzLmNyeXB0by5wYXNzd29yZHV0aWwqLmphciIvPgogICAgICAgICAgICA8L2NvbW1vbkxpYnJhcnk+CiAgICAgICAgPC9jbGFzc2xvYWRlcj4KICAgIDwvYXBwbGljYXRpb24+CiAgICAKICAgIDwhLS0gRGVjbGFyZSB0aGUgamFyIGZpbGVzIGZvciBEQjIgYWNjZXNzIHRocm91Z2ggSkRCQy4gLS0+CiAgICA8bGlicmFyeSBpZD0ibWZwYWRtaW4vREIyTGliIj4KICAgICAgICA8ZmlsZXNldCBkaXI9IiR7c2hhcmVkLnJlc291cmNlLmRpcn0vbGliIiBpbmNsdWRlcz0iZGIyamNjNC5qYXIiLz4KICAgIDwvbGlicmFyeT4KICAgIAogICAgPGFwcGxpY2F0aW9uIGNvbnRleHQtcm9vdD0iZG9jIiBpZD0ic3dhZ2dlci11aSIgbG9jYXRpb249Im1mcC1zZXJ2ZXItc3dhZ2dlci11aS53YXIiIG5hbWU9InN3YWdnZXItdWkiIHR5cGU9IndhciIvPgoKCTwhLS0gSk5ESSBmb3IgdGhlIHN3YWdnZXIgdWksIHNvIHRoZSBhZG1pbiBjb25zb2xlIGNhbiBwcmVzZW50IGEgbGluayB0byBvcGVuIHRoZSBhZGFwdGVyIGluZm9ybWF0aW9uIGluIHRoZSBzd2FnZ2VyIHVpIC0tPgogICAgPGpuZGlFbnRyeSBqbmRpTmFtZT0iJHtlbnYuTUZQRl9BRE1JTl9ST09UfS9tZnAuc2VydmVyLnN3YWdnZXIudWkudXJsIiB2YWx1ZT0iL2RvYy8/dXJsPS8mbHQ7Y29udGV4dCZndDsvYXBpL2FkYXB0ZXJkb2MvJmx0O2FkYXB0ZXJOYW1lJmd0OyIvPgoJCgk8IS0tIERlY2xhcmUgdGhlIE1vYmlsZUZpcnN0IFBsYXRmb3JtIEZvdW5kYXRpb24gQWRtaW5pc3RyYXRpb24gQ29uc29sZSBhcHBsaWNhdGlvbi4gLS0+CiAgICA8YXBwbGljYXRpb24gaWQ9IiR7ZW52Lk1GUEZfQ09OU09MRV9ST09UfSIgbmFtZT0iJHtlbnYuTUZQRl9DT05TT0xFX1JPT1R9IiBsb2NhdGlvbj0ibWZwLWFkbWluLXVpLndhciIgdHlwZT0id2FyIj4KICAgICAgICA8YXBwbGljYXRpb24tYm5kPgogICAgICAgICAgICA8c2VjdXJpdHktcm9sZSBuYW1lPSJtZnBhZG1pbiI+CiAgICAgICAgICAgICAgICA8Z3JvdXAgbmFtZT0iJHtlbnYuTUZQRl9BRE1JTl9HUk9VUH0iLz4KICAgICAgICAgICAgPC9zZWN1cml0eS1yb2xlPgogICAgICAgICAgICAKICAgICAgICAgICAgPHNlY3VyaXR5LXJvbGUgbmFtZT0ibWZwZGVwbG95ZXIiPgogICAgICAgICAgICAgICAgPGdyb3VwIG5hbWU9IiR7ZW52Lk1GUEZfREVQTE9ZRVJfR1JPVVB9Ii8+CiAgICAgICAgICAgIDwvc2VjdXJpdHktcm9sZT4KICAgICAgICAgICAgCiAgICAgICAgICAgIDxzZWN1cml0eS1yb2xlIG5hbWU9Im1mcG1vbml0b3IiPgogICAgICAgICAgICAgICAgPGdyb3VwIG5hbWU9IiR7ZW52Lk1GUEZfTU9OSVRPUl9HUk9VUH0iLz4KICAgICAgICAgICAgPC9zZWN1cml0eS1yb2xlPgogICAgICAgICAgICAKICAgICAgICAgICAgPHNlY3VyaXR5LXJvbGUgbmFtZT0ibWZwb3BlcmF0b3IiPgogICAgICAgICAgICAgICAgPGdyb3VwIG5hbWU9IiR7ZW52Lk1GUEZfT1BFUkFUT1JfR1JPVVB9Ii8+CiAgICAgICAgICAgIDwvc2VjdXJpdHktcm9sZT4KICAgICAgICA8L2FwcGxpY2F0aW9uLWJuZD4KCQk8Y2xhc3Nsb2FkZXIgZGVsZWdhdGlvbj0icGFyZW50TGFzdCIvPgogICAgPC9hcHBsaWNhdGlvbj4KICAgIAogICAgPCEtLSBEZWNsYXJlIHRoZSBKTkRJIHByb3BlcnRpZXMgZm9yIHRoZSBNb2JpbGVGaXJzdCBBZG1pbmlzdHJhdGlvbiBDb25zb2xlLiAtLT4KICAgIDxqbmRpRW50cnkgam5kaU5hbWU9IiR7ZW52Lk1GUEZfQ09OU09MRV9ST09UfS9tZnAuYWRtaW4uZW5kcG9pbnQiIHZhbHVlPSIqOi8vKjoqLyR7ZW52Lk1GUEZfQURNSU5fUk9PVH0iLz4KICAgIAogICAgPCEtLSBEZWNsYXJlIHRoZSBNb2JpbGVGaXJzdCBDb25maWd1cmF0aW9uIFNlcnZpY2UgYXBwbGljYXRpb24uIC0tPgogICAgPGFwcGxpY2F0aW9uIGlkPSIke2Vudi5NRlBGX0NPTkZJR19ST09UfSIgbmFtZT0iJHtlbnYuTUZQRl9DT05GSUdfUk9PVH0iIGxvY2F0aW9uPSJtZnAtY29uZmlnLXNlcnZpY2Uud2FyIiB0eXBlPSJ3YXIiPgogICAgICAgIDxhcHBsaWNhdGlvbi1ibmQ+CiAgICAgICAgICAgIDxzZWN1cml0eS1yb2xlIG5hbWU9ImNvbmZpZ2FkbWluIj4KICAgICAgICAgICAgICAgIDxncm91cCBuYW1lPSIke2Vudi5NRlBGX0FETUlOX0dST1VQfSIvPgoKICAgICAgICAgICAgPC9zZWN1cml0eS1yb2xlPgoKICAgICAgICA8L2FwcGxpY2F0aW9uLWJuZD4KCiAgICAgICAgPGNsYXNzbG9hZGVyIGRlbGVnYXRpb249InBhcmVudExhc3QiLz4KICAgIDwvYXBwbGljYXRpb24+CgogICAgPCEtLSBEZWNsYXJlIHRoZSBKTkRJIHByb3BlcnRpZXMgZm9yIHRoZSBNb2JpbGVGaXJzdCBDb25maWd1cmF0aW9uIFNlcnZpY2UuIC0tPgogICAgCiAgICA8IS0tIEVuZCBvZiBjb25maWd1cmF0aW9uIGFkZGVkIGJ5IElCTSBNb2JpbGVGaXJzdCA8aW5zdGFsbG1vYmlsZWZpcnN0YWRtaW4+IGFudCB0YXNrIGZvciBjb250ZXh0IHJvb3QgJy9tZnBhZG1pbicuIC0tPgogICAgCiAgICA8IS0tIERlY2xhcmUgdGhlIE1vYmlsZUZpcnN0IFJ1bnRpbWUgYXBwbGljYXRpb24uIC0tPgoJPGFwcGxpY2F0aW9uIGlkPSIke2Vudi5NRlBGX1JVTlRJTUVfUk9PVH0iIG5hbWU9IiR7ZW52Lk1GUEZfUlVOVElNRV9ST09UfSIgbG9jYXRpb249Im1mcC1zZXJ2ZXIud2FyIiB0eXBlPSJ3YXIiPgoJICAgIDxjbGFzc2xvYWRlciBkZWxlZ2F0aW9uPSJwYXJlbnRMYXN0Ij4KCSAgICA8cHJpdmF0ZUxpYnJhcnkgaWQ9Im1mcGxpYl9tZnAiPgoJCTxmaWxlc2V0IGRpcj0iJHt3bHAuaW5zdGFsbC5kaXJ9L2xpYiIgaW5jbHVkZXM9ImNvbS5pYm0ud3MuY3J5cHRvLnBhc3N3b3JkdXRpbCouamFyIi8+CgkJPC9wcml2YXRlTGlicmFyeT4KCQk8L2NsYXNzbG9hZGVyPgoJPC9hcHBsaWNhdGlvbj4KCjwhLS0gRGVjbGFyZSB0aGUgTW9iaWxlRmlyc3QgT3BlcmF0aW9uYWwgQW5hbHl0aWNzIFNlcnZpY2UgYXBwbGljYXRpb24uIC0tPgogICAgPGFwcGxpY2F0aW9uIGlkPSJhbmFseXRpY3Mtc2VydmljZSIgbmFtZT0iYW5hbHl0aWNzLXNlcnZpY2UiIGxvY2F0aW9uPSJhbmFseXRpY3Mtc2VydmljZS53YXIiIHR5cGU9IndhciI+CiAgICAgICAgPGFwcGxpY2F0aW9uLWJuZD4KICAgICAgICAgICAgPHNlY3VyaXR5LXJvbGUgbmFtZT0iYW5hbHl0aWNzX2FkbWluaXN0cmF0b3IiPgogICAgICAgICAgICAgICAgPHVzZXIgbmFtZT0iYW14Z2EiLz4KICAgICAgICAgICAgPC9zZWN1cml0eS1yb2xlPgogICAgICAgICAgICA8c2VjdXJpdHktcm9sZSBuYW1lPSJhbmFseXRpY3NfaW5mcmFzdHJ1Y3R1cmUiPgogICAgICAgICAgICA8L3NlY3VyaXR5LXJvbGU+CiAgICAgICAgICAgIDxzZWN1cml0eS1yb2xlIG5hbWU9ImFuYWx5dGljc19zdXBwb3J0Ij4KICAgICAgICAgICAgPC9zZWN1cml0eS1yb2xlPgogICAgICAgICAgICA8c2VjdXJpdHktcm9sZSBuYW1lPSJhbmFseXRpY3NfZGV2ZWxvcGVyIj4KICAgICAgICAgICAgPC9zZWN1cml0eS1yb2xlPgogICAgICAgICAgICA8c2VjdXJpdHktcm9sZSBuYW1lPSJhbmFseXRpY3NfYnVzaW5lc3MiPgogICAgICAgICAgICA8L3NlY3VyaXR5LXJvbGU+CiAgICAgICAgPC9hcHBsaWNhdGlvbi1ibmQ+CiAgICAgICAgPGNsYXNzbG9hZGVyIGRlbGVnYXRpb249InBhcmVudExhc3QiPgogICAgICAgICAgICA8L2NsYXNzbG9hZGVyPgogICAgPC9hcHBsaWNhdGlvbj4KICAgIDwhLS0gRGVjbGFyZSB0aGUgSk5ESSBwcm9wZXJ0aWVzIGZvciB0aGUgTW9iaWxlRmlyc3QgT3BlcmF0aW9uYWwgQW5hbHl0aWNzIFNlcnZpY2UuIC0tPgogICAgPGpuZGlFbnRyeSBqbmRpTmFtZT0iYW5hbHl0aWNzL3NoYXJkcyIgdmFsdWU9JyI1IicvPgogICAgCgogICAgPCEtLSBEZWNsYXJlIHRoZSBNb2JpbGVGaXJzdCBPcGVyYXRpb25hbCBBbmFseXRpY3MgQ29uc29sZSBhcHBsaWNhdGlvbi4gLS0+CiAgICA8YXBwbGljYXRpb24gaWQ9ImFuYWx5dGljcyIgbmFtZT0iYW5hbHl0aWNzIiBsb2NhdGlvbj0iYW5hbHl0aWNzLXVpLndhciIgdHlwZT0id2FyIj4KICAgICAgICA8YXBwbGljYXRpb24tYm5kPgogICAgICAgICAgICA8c2VjdXJpdHktcm9sZSBuYW1lPSJhbmFseXRpY3NfYWRtaW5pc3RyYXRvciI+CiAgICAgICAgICAgICAgICA8dXNlciBuYW1lPSJhbXhnYSIvPgogICAgICAgICAgICA8L3NlY3VyaXR5LXJvbGU+CiAgICAgICAgICAgIDxzZWN1cml0eS1yb2xlIG5hbWU9ImFuYWx5dGljc19pbmZyYXN0cnVjdHVyZSI+CiAgICAgICAgICAgIDwvc2VjdXJpdHktcm9sZT4KICAgICAgICAgICAgPHNlY3VyaXR5LXJvbGUgbmFtZT0iYW5hbHl0aWNzX3N1cHBvcnQiPgogICAgICAgICAgICA8L3NlY3VyaXR5LXJvbGU+CiAgICAgICAgICAgIDxzZWN1cml0eS1yb2xlIG5hbWU9ImFuYWx5dGljc19kZXZlbG9wZXIiPgogICAgICAgICAgICA8L3NlY3VyaXR5LXJvbGU+CiAgICAgICAgICAgIDxzZWN1cml0eS1yb2xlIG5hbWU9ImFuYWx5dGljc19idXNpbmVzcyI+CiAgICAgICAgICAgIDwvc2VjdXJpdHktcm9sZT4KICAgICAgICA8L2FwcGxpY2F0aW9uLWJuZD4KICAgIDwvYXBwbGljYXRpb24+CgogICAgPCEtLSBEZWNsYXJlIHRoZSBKTkRJIHByb3BlcnRpZXMgZm9yIHRoZSBNb2JpbGVGaXJzdCBPcGVyYXRpb25hbCBBbmFseXRpY3MgQ29uc29sZS4gLS0+CjxqbmRpRW50cnkgam5kaU5hbWU9ImFuYWx5dGljc2NvbnNvbGUvbWZwLmFuYWx5dGljcy51cmwiIHZhbHVlPSciKjovLyo6Ki9hbmFseXRpY3Mtc2VydmljZSInLz4KPGpuZGlFbnRyeSBqbmRpTmFtZT0ibWZwL21mcC5hbmFseXRpY3MudXJsIiB2YWx1ZT0nImh0dHA6Ly8xMC4yMy4xNDMuODo5MDgyL2FuYWx5dGljcy1zZXJ2aWNlIicvPgo8am5kaUVudHJ5IGpuZGlOYW1lPSJtZnAvbWZwLmFuYWx5dGljcy5jb25zb2xlLnVybCIgdmFsdWU9JyJodHRwOi8vMTAuMjMuMTQzLjg6OTA4Mi9hbmFseXRpY3MvY29uc29sZSInLz4KPGpuZGlFbnRyeSBqbmRpTmFtZT0ibWZwL21mcC5hbmFseXRpY3MudXNlcm5hbWUiIHZhbHVlPSciYW14Z2EiJy8+CjxqbmRpRW50cnkgam5kaU5hbWU9Im1mcC9tZnAuYW5hbHl0aWNzLnBhc3N3b3JkIiB2YWx1ZT0nImFiY2QxMjM0IicvPgo8am5kaUVudHJ5IGpuZGlOYW1lPSJpbWZwdXNoL21mcC5wdXNoLmFuYWx5dGljcy5lbmRwb2ludCIgdmFsdWU9JyJodHRwOi8vMTAuMjMuMTQzLjg6OTA4Mi9hbmFseXRpY3Mtc2VydmljZSInLz4KPGpuZGlFbnRyeSBqbmRpTmFtZT0iaW1mcHVzaC9tZnAucHVzaC5hbmFseXRpY3MudXNlciIgdmFsdWU9JyJhbXhnYSInLz4KPGpuZGlFbnRyeSBqbmRpTmFtZT0iaW1mcHVzaC9tZnAucHVzaC5hbmFseXRpY3MucGFzc3dvcmQiIHZhbHVlPSciYWJjZDEyMzQiJy8+CjxqbmRpRW50cnkgam5kaU5hbWU9ImltZnB1c2gvbWZwLnB1c2guc2VydmljZXMuZXh0LmFuYWx5dGljcyIgdmFsdWU9JyJjb20uaWJtLm1mcC5wdXNoLnNlcnZlci5hbmFseXRpY3MucGx1Z2luLkFuYWx5dGljc1BsdWdpbiInLz4KCjxqbmRpRW50cnkgam5kaU5hbWU9Im1mcC5hZG1pbi5mYXJtLmhlYXJ0YmVhdCIgdmFsdWU9JyIxMCInLz4KPGpuZGlFbnRyeSBqbmRpTmFtZT0ibWZwLmFkbWluLmZhcm0ubWlzc2VkLmhlYXJ0YmVhdHMudGltZW91dCIgdmFsdWU9JyIxMCInLz4KPGpuZGlFbnRyeSBqbmRpTmFtZT0ibWZwLmFkbWluLmZhcm0ucmVpbml0aWFsaXplIiB2YWx1ZT0nInRydWUiJy8+Cjwvc2VydmVyPg==" | \
    base64 -d -w0 > /opt/ibm/wlp/usr/servers/mfp/server.xml

    echo "TUZQRl9TRVJWRVJfSFRUUFBPUlQ9OTA4MApNRlBGX1NFUlZFUl9IVFRQU1BPUlQ9OTQ0MwoKTUZQRl9DTFVTVEVSX01PREU9U3RhbmRhbG9uZQoKTUZQRl9BRE1JTl9ST09UPW1mcGFkbWluCk1GUEZfQ09OU09MRV9ST09UPW1mcGNvbnNvbGUKTUZQRl9DT05GSUdfUk9PVD1tZnBhZG1pbmNvbmZpZwpNRlBGX1BVU0hfUk9PVD1pbWZwdXNoCk1GUEZfUlVOVElNRV9ST09UPW1mcAoKTUZQRl9BRE1JTl9HUk9VUD1tZnBhZG1pbmdyb3VwCk1GUEZfREVQTE9ZRVJfR1JPVVA9bWZwZGVwbG95ZXJncm91cApNRlBGX01PTklUT1JfR1JPVVA9bWZwbW9uaXRvcmdyb3VwCk1GUEZfT1BFUkFUT1JfR1JPVVA9bWZwb3BlcmF0b3Jncm91cAoKTUZQRl9BRE1JTl9VU0VSPWFteGdhCk1GUEZfQURNSU5fUEFTU1dPUkQ9YWJjZDEyMzQKCk1GUEZfU0VSVkVSX0FETUlOX1VTRVI9bWZwUkVTVFVzZXIKTUZQRl9TRVJWRVJfQURNSU5fUEFTU1dPUkQ9bWZwYWRtaW4KCgpNRlBGX0RCMl9TRVJWRVJfTkFNRT0KTUZQRl9EQjJfUE9SVD0KTUZQRl9EQjJfREFUQUJBU0VfTkFNRT0KTUZQRl9EQjJfVVNFUk5BTUU9Ck1GUEZfREIyX1BBU1NXT1JEPQpNRlBGX0RCMl9TQ0hFTUE9CgoKCk1GUEZfQURNSU5fREIyX1NFUlZFUl9OQU1FPTE3Mi4xNy4wLjIKTUZQRl9BRE1JTl9EQjJfUE9SVD01MDAwMApNRlBGX0FETUlOX0RCMl9EQVRBQkFTRV9OQU1FPU1GUERBVEEKTUZQRl9BRE1JTl9EQjJfVVNFUk5BTUU9ZGIyYW14Ck1GUEZfQURNSU5fREIyX1BBU1NXT1JEPW1pcGFzc3dvcmRtdXlzZWNyZXRvCk1GUEZfQURNSU5fREIyX1NDSEVNQT1NRlBEQVRBClNTTF9DT05ORUNUSU9OPWZhbHNlCgpNRlBGX1JVTlRJTUVfREIyX1NFUlZFUl9OQU1FPTE3Mi4xNy4wLjIKTUZQRl9SVU5USU1FX0RCMl9QT1JUPTUwMDAwCk1GUEZfUlVOVElNRV9EQjJfREFUQUJBU0VfTkFNRT1NRlBEQVRBCk1GUEZfUlVOVElNRV9EQjJfVVNFUk5BTUU9ZGIyYW14Ck1GUEZfUlVOVElNRV9EQjJfUEFTU1dPUkQ9bWlwYXNzd29yZG11eXNlY3JldG8KTUZQRl9SVU5USU1FX0RCMl9TQ0hFTUE9TUZQREFUQQoKTUZQRl9QVVNIX0RCMl9TRVJWRVJfTkFNRT0xNzIuMTcuMC4yCk1GUEZfUFVTSF9EQjJfUE9SVD01MDAwMApNRlBGX1BVU0hfREIyX0RBVEFCQVNFX05BTUU9TUZQREFUQQpNRlBGX1BVU0hfREIyX1VTRVJOQU1FPWRiMmFteApNRlBGX1BVU0hfREIyX1BBU1NXT1JEPW1pcGFzc3dvcmRtdXlzZWNyZXRvCk1GUEZfUFVTSF9EQjJfU0NIRU1BPU1GUERBVEEKCklQX0FERFJFU1M9bG9jYWxob3N0CkhPU1ROQU1FPWxvY2FsaG9zdApBRE1JTl9IT1NUPTE3Mi4xNy4wLjMK" | base64 -d -w0 > /opt/ibm/wlp/usr/servers/mfp/server.env

    check_variables_mfpf
fi

export LD_LIBRARY_PATH=/opt/rh/devtoolset-3/root/usr/lib64/
while [ ${MAIN_PROC_RUN} -eq 1 ]; do
    if [ "${FIRST_RUN}" -eq 0 ] ; then
        FIRST_RUN=1
        /opt/ibm/wlp/bin/server start mfp
        sleep 10
        echo "[AMX] Mobilfirst is Started"
    fi
done