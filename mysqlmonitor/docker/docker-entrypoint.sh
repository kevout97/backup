#!/bin/bash

# By: Mauricio & Kevs | AMX GA/DT

export LD_LIBRARY_PATH=/opt/rh/devtoolset-3/root/usr/lib64/
FIRST_RUN=0
MAIN_PID=$$
MAIN_PROC_RUN=1
COMMAND=""

env > /tmp/.env

trap "docker_stop" SIGINT SIGTERM

function docker_stop {
    if [ -n "${MYSQLM_AGENT}" ] && [ "${MYSQLM_AGENT}" == "TRUE" -o "${MYSQLM_AGENT}" == "true" ] ; then
        echo "[AMX] Rcv end signal"
        /opt/mysql/enterprise/agent/etc/init.d/mysql-monitor-agent stop 1>/dev/null
        export MAIN_PROC_RUN=0
    else
        echo "[AMX] Rcv end signal"
        /opt/mysql/enterprise/monitor/mysqlmonitorctl.sh stop 1>/dev/null
        export MAIN_PROC_RUN=0
    fi
}
function check_variables_server(){

    if [ ! -z "${MYSQLM_ADMIN_USER}" ]; then
        COMMAND="$COMMAND --adminuser $MYSQLM_ADMIN_USER"
    else
        echo "[AMX] MYSQLM_ADMIN_USER not found"
        exit 1
    fi

    if [ ! -z "${MYSQLM_ADMIN_PASSWORD}" ]; then
        COMMAND="$COMMAND --adminpassword $MYSQLM_ADMIN_PASSWORD"
    else
        echo "[AMX] MYSQLM_ADMIN_PASSWORD not found"
        exit 1
    fi

    if [ ! -z "${MYSQLM_SYSTEM_SIZE}" ]; then
        COMMAND="$COMMAND --system_size $MYSQLM_SYSTEM_SIZE"
    else
        echo "[AMX] MYSQLM_SYSTEM_SIZE not found"
        exit 1
    fi

    if [ ! -z "${MYSQLM_DB_HOST}" ] && [ "${MYSQLM_DB_HOST}" != "127.0.0.1" ] && [ "${MYSQLM_DB_HOST}" != "localhost" ]; then
        COMMAND="$COMMAND --mysql_installation_type existing --dbhost $MYSQLM_DB_HOST"
    fi

    if [ ! -z "${MYSQLM_DB_PORT}" ]; then
        COMMAND="$COMMAND --dbport $MYSQLM_DB_PORT"
    fi

    if [ ! -z "${MYSQLM_DB_NAME}" ]; then
        COMMAND="$COMMAND --dbname $MYSQLM_DB_NAME"
    fi
}

function check_variables_agent(){
    if [ ! -z "${MYSQLM_AGENT_USER}" ]; then
        COMMAND="$COMMAND --agentuser $MYSQLM_AGENT_USER"
    else
        echo "[AMX] MYSQLM_AGENT_USER not found"
        exit 1
    fi

    if [ ! -z "${MYSQLM_AGENT_PASSWORD}" ]; then
        COMMAND="$COMMAND --agentpassword $MYSQLM_AGENT_PASSWORD"
    else
        echo "[AMX] MYSQLM_AGENT_PASSWORD not found"
        exit 1
    fi

    if [ ! -z "${MYSQLM_AGENT_MANAGER_HOST}" ]; then
        COMMAND="$COMMAND --managerhost $MYSQLM_AGENT_MANAGER_HOST"
    else
        echo "[AMX] MYSQLM_AGENT_MANAGER_HOST not found"
        exit 1
    fi

    if [ ! -z "${MYSQLM_AGENT_MANAGER_PORT}" ]; then
        COMMAND="$COMMAND --managerport $MYSQLM_AGENT_MANAGER_PORT"
    else
        echo "[AMX] MYSQLM_AGENT_MANAGER_PORT not found"
        exit 1
    fi
}

while [ ${MAIN_PROC_RUN} -eq 1 ]; do
    if [ "${FIRST_RUN}" -eq 0 ] ; then
        FIRST_RUN=1
        if [ -n "${MYSQLM_AGENT}" ] && [ "${MYSQLM_AGENT}" == "TRUE" -o "${MYSQLM_AGENT}" == "true" ] ; then
            echo "[AMX] Install MysqlMonitor Agent"
            COMMAND="/opt/mysqlmonitor-files/mysqlmonitor-agent/mysqlmonitoragent-$MYSQL_MONITOR_VERSION.installer.bin --mode unattended --agent_installtype standalone --installdir /opt/mysql/enterprise/agent/"
            if [ ! -z "$(ls -A /opt/mysql/enterprise/agent)" ]; then
                echo "[AMX] Directory of MysqlMonitor Agent isn't empty"
                echo "[AMX] Starting MysqlMonitor Agent..."
                /opt/mysql/enterprise/agent/etc/init.d/mysql-monitor-agent start 1>/dev/null
                sleep 15
                /opt/mysql/enterprise/agent/etc/init.d/mysql-monitor-agent restart 1>/dev/null
                sleep 15
                echo "[AMX] MysqlMonitor Agent is Started"
            else
                echo "[AMX] Directory of MysqlMonitor is empty"
                echo "[AMX] Creating MysqlMonitor Agent"
                check_variables_agent
                $COMMAND
                /opt/mysql/enterprise/agent/etc/init.d/mysql-monitor-agent start 1>/dev/null
                sleep 15
                echo "[AMX] MysqlMonitor Agent is Started"
            fi
        else
            COMMAND="/opt/mysqlmonitor-files/mysqlmonitor-server/mysqlmonitor-$MYSQL_MONITOR_VERSION.installer.bin --mode unattended --installdir /opt/mysql/enterprise/monitor/"
            echo "[AMX] Install MysqlMonitor Server"
            if [ ! -z "$(ls -A /opt/mysql/enterprise/monitor)" ]; then
                echo "[AMX] Directory of MysqlMonitor isn't empty"
                echo "[AMX] Sarting Services.."
                /opt/mysql/enterprise/monitor/mysqlmonitorctl.sh start 1>/dev/null
                sleep 15
                /opt/mysql/enterprise/monitor/mysqlmonitorctl.sh restart 1>/dev/null
                sleep 15
                echo "[AMX] MysqlMonitor is Started"
            else
                echo "[AMX] Directory of MysqlMonitor is empty"
                echo "[AMX] Creating MysqlMonitor Server"
                check_variables_server
                $COMMAND
                echo "[AMX] MysqlMonitor is Started"
            fi
        fi
    fi
    sleep 2
done