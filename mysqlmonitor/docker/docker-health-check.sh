#!/bin/bash

. /tmp/.env

export LD_LIBRARY_PATH=/opt/rh/devtoolset-3/root/usr/lib64/
TOMCAT_PIDFILE=/opt/mysql/enterprise/monitor/apache-tomcat/temp/catalina.pid
PID=""
TOMCAT_PID=""

get_pid() {
    PID=""
    PIDFILE=$1
    # check for pidfile
    if [ -f $PIDFILE ] ; then
        PID=`cat $PIDFILE`
    fi
}

get_tomcat_pid() {
    get_pid $TOMCAT_PIDFILE
    if [ ! "$PID" ]; then
        return
    fi
    if [ $PID -gt 0 ]; then
        TOMCAT_PID=$PID
        JSVC_PID=`ps -p $TOMCAT_PID -o ppid=`
    fi
}

is_service_running() {
    PID=$1
    if [ "x$PID" != "x" ] && kill -0 $PID 2>/dev/null ; then
        RUNNING=0
    else
        RUNNING=1
    fi
    return $RUNNING
}

if [ -n "${MYSQLM_AGENT}" ] && [ "${MYSQLM_AGENT}" == "TRUE" -o "${MYSQLM_AGENT}" == "true" ] ; then
    /opt/mysql/enterprise/agent/etc/init.d/mysql-monitor-agent status
else
    if [ ! -z "${MYSQLM_DB_HOST}" ] && [ "${MYSQLM_DB_HOST}" != "127.0.0.1" ] && [ "${MYSQLM_DB_HOST}" != "localhost" ]; then
        get_tomcat_pid
        is_service_running $TOMCAT_PID
    else
        /opt/mysql/enterprise/monitor/mysqlmonitorctl.sh status
    fi
fi

exit $?
