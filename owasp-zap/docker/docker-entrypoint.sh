#!/bin/bash

# Created by Mauricio & Kev | AMX GADT

export HOME=/opt/owasp-zap/webswing
export OPTS="-h 0.0.0.0 -j $HOME/jetty.properties -c $HOME/webswing.config"
export JAVA_OPTS="-Xmx128M"
export LOG=$HOME/webswing.out
export PID_PATH_NAME=$HOME/webswing.pid
FIRST_RUN=3
MAIN_PROC_RUN=1

function docker_stop {
    echo "[AMX] $(date) Rcv end signal"
    kill -9 $(pgrep java)
    kill -9 $(pgrep Xvfb)
    export MAIN_PROC_RUN=0
}

function check_variables(){
    if [ "${ZAP_PORT_PROXY}" == "8080" ] || [ -z "${ZAP_PORT_PROXY}" ]; then
        ZAP_PORT_PROXY=9090
        echo "[AMX $(date +'%Y-%m-%d %R')] Zaproxy Proxy is going to expose by port 9090"
    else
        export ZAP_PORT=$ZAP_PORT_PROXY
    fi

    if [ -n "${ZAP_PORT_WEB}" ]; then
        sed -i "s%org.webswing.server.http.port=.*%org.webswing.server.http.port=$ZAP_PORT_WEB%g" $HOME/jetty.properties
    else
        ZAP_PORT_WEB=8080
    fi
}

Xvfb :0.0 &
check_variables

while [ ${MAIN_PROC_RUN} -eq 1 ]; do
    if [ $(echo ${ZAP_FULL_SCAN,,}) == "true" ]; then
        zap-full-scan.py $ZAP_FS_OPTIONS
        exit 0
    else
        if [ "${FIRST_RUN}" -eq 2 ] || [ "${FIRST_RUN}" -eq 3 ] ; then
            echo "[AMX $(date +'%Y-%m-%d %R')] Starting Zaproxy Web..."
            xvfb-run $JAVA_HOME/bin/java $JAVA_OPTS -jar $HOME/webswing-server.war $OPTS 2>> $LOG >> $LOG &
            sleep 15
            echo "[AMX $(date +'%Y-%m-%d %R')] Zaproxy Web is listening by http://0.0.0.0:$ZAP_PORT_WEB/zap"
        fi

        if [ "${FIRST_RUN}" -eq 1 ] || [ "${FIRST_RUN}" -eq 3 ] ; then
            echo "" > /opt/owasp-zap/zap-proxy.log
            echo "[AMX $(date +'%Y-%m-%d %R')] Starting Zaproxy Proxy..."
            zap.sh -daemon -host 0.0.0.0 -port $ZAP_PORT_PROXY -config api.addrs.addr.name=.* -config api.addrs.addr.regex=true -config api.disablekey=true 2>>/opt/owasp-zap/zap-proxy.log >>/opt/owasp-zap/zap-proxy.log &
            sleep 15
            echo "[AMX $(date +'%Y-%m-%d %R')] Zaproxy Proxy is listening by http://0.0.0.0:$ZAP_PORT_PROXY"
        fi
        
        /sbin/docker-health-check.sh
        FIRST_RUN=$?
    fi
done
