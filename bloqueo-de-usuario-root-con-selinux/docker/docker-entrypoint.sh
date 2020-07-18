#!/bin/bash

# Mauricio Melendez & Kevin Gómez | AMX GA/DT

export LD_LIBRARY_PATH=/opt/rh/devtoolset-3/root/usr/lib64/
FIRST_RUN=1
MAIN_PID=$$
MAIN_PROC_RUN=1

function check_variables(){
    if [ -z "${MONITORING_RSYSLOG_HOST}" ]; then
        echo "[AMX $(date)] MONITORING_RSYSLOG_HOST not found"
        exit 1
    fi

    if [ -z "${MONITORING_RSYSLOG_PORT}" ]; then
        echo "[AMX $(date)] MONITORING_RSYSLOG_PORT not found"
        exit 1
    fi

    if [ -z "${MONITORING_DIRECTORIES}" ]; then
        echo "[AMX $(date)] MONITORING_DIRECTORIES not found"
        exit 1
    fi

    if [ "$(echo ${MONITORING_RSYSLOG_PROTOCOL,,})" != "udp" ] && [ "$(echo ${MONITORING_RSYSLOG_PROTOCOL,,})" != "tcp" ]; then
        echo "[AMX $(date)] MONITORING_RSYSLOG_PROTOCOL not found"
        exit 1
    else
        export MONITORING_RSYSLOG_PROTOCOL=$(echo "${MONITORING_RSYSLOG_PROTOCOL,,}")
    fi
}

echo "[AMX $(date)] Starting Monitoring"
while [ ${MAIN_PROC_RUN} -eq 1 ]; do
    if [ "${FIRST_RUN}" -ne 0 ] ; then
        python /sbin/python-monitoring.py
    fi
    /sbin/docker-health-check.sh
    FIRST_RUN=$?
done