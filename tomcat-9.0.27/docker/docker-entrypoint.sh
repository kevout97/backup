#!/bin/bash
# Created by Berryrreb & Kevs | If you want something to go well, do it right

TOMCAT_DIRECTORY=/usr/local/apache-tomcat-$TOMCAT_VERSION
FIRST_RUN=0
MAIN_PID=$$
MAIN_PROC_RUN=1

env > /tmp/.env

trap "docker_stop" SIGINT SIGTERM

function docker_stop {
    echo "[AMX] Rcv end signal"
    $TOMCAT_DIRECTORY/bin/shutdown.sh 1>/dev/null
    export MAIN_PROC_RUN=0
}

function check_variables(){
    if [ ! -z "${TOMCAT_USER_GUI}" ] && [ ! -z "${TOMCAT_PASSWORD_GUI}" ] ; then
        echo "[AMX] Create $TOMCAT_USER_GUI user"
        sed -i "s%<\/tomcat-users>%<role rolename=\"manager-gui\"\/>\n<role rolename=\"admin-gui\"\/>\n<user username=\"$TOMCAT_USER_GUI\" password=\"$TOMCAT_PASSWORD_GUI\" roles=\"admin-gui,manager-gui\"\/>\n<\/tomcat-users>%g" $TOMCAT_DIRECTORY/conf/tomcat-users.xml
    fi

    if [ ! -z "${MAX_FILE_SIZE}" ]; then
        echo "[AMX] Update Max file size"
        sed -i "s/<max-request-size>.*/<max-request-size>$MAX_FILE_SIZE<\/max-request-size>/g" $TOMCAT_DIRECTORY/webapps/manager/WEB-INF/web.xml
        sed -i "s/<max-file-size>.*/<max-file-size>$MAX_FILE_SIZE<\/max-file-size>/g" $TOMCAT_DIRECTORY/webapps/manager/WEB-INF/web.xml
        if [ "$(cat $TOMCAT_DIRECTORY/conf/server.xml | grep -m 1 -o maxPostSize)" == "maxPostSize" ]; then
            sed -i "s/\n\t\tmaxPostSize=\".*/\n\t\tmaxPostSize=\"$MAX_FILE_SIZE\"/g" $TOMCAT_DIRECTORY/conf/server.xml
        else
            sed -i "s/connectionTimeout=\".*/connectionTimeout=\"2000\"\n\t\tmaxPostSize=\"$MAX_FILE_SIZE\"/g" $TOMCAT_DIRECTORY/conf/server.xml
        fi
    fi

    if [ ! -z "${CONNECTION_TIMEOUT}" ]; then
        echo "[AMX] Update Connection Timeout"
        sed -i "s/connectionTimeout=\".*/connectionTimeout=\"$CONNECTION_TIMEOUT\"/g" $TOMCAT_DIRECTORY/conf/server.xml
    fi
}

echo "[AMX] Configuring webapps directory"
tar -xzf /opt/tomcat-files/tomcat-webapps.tar.gz -C $TOMCAT_DIRECTORY/
$TOMCAT_DIRECTORY/bin/startup.sh 1>/dev/null
sleep 15

echo "[AMX] Allow access to the Manager UI"
mkdir -p $TOMCAT_DIRECTORY/conf/Catalina/localhost
echo 'PENvbnRleHQgcHJpdmlsZWdlZD0idHJ1ZSIgYW50aVJlc291cmNlTG9ja2luZz0iZmFsc2UiCiAgZG9jQmFzZT0iJHtjYXRhbGluYS5ob21lfS93ZWJhcHBzL21hbmFnZXIiPgo8VmFsdmUgY2xhc3NOYW1lPSJvcmcuYXBhY2hlLmNhdGFsaW5hLnZhbHZlcy5SZW1vdGVBZGRyVmFsdmUiIGFsbG93PSJeLiokIiAvPgo8L0NvbnRleHQ+Cg==' | base64 -w0 -d > $TOMCAT_DIRECTORY/conf/Catalina/localhost/manager.xml
echo 'PENvbnRleHQgcHJpdmlsZWdlZD0idHJ1ZSIgYW50aVJlc291cmNlTG9ja2luZz0iZmFsc2UiIGRvY0Jhc2U9IiR7Y2F0YWxpbmEuaG9tZX0vd2ViYXBwcy9ob3N0LW1hbmFnZXIiPgogICAgPFZhbHZlIGNsYXNzTmFtZT0ib3JnLmFwYWNoZS5jYXRhbGluYS52YWx2ZXMuUmVtb3RlQWRkclZhbHZlIiBhbGxvdz0iXi4qJCIgLz4KPC9Db250ZXh0Pgo=' | base64 -w0 -d > $TOMCAT_DIRECTORY/conf/Catalina/localhost/host-manager.xml
check_variables

echo "[AMX] Making changes effective"
$TOMCAT_DIRECTORY/bin/shutdown.sh 1>/dev/null
sleep 15

echo "[AMX] Starting Tomcat" 

while [ ${MAIN_PROC_RUN} -eq 1 ]; do
    if [ "${FIRST_RUN}" -eq 0 ] ; then
        FIRST_RUN=1
        $TOMCAT_DIRECTORY/bin/startup.sh
        echo "[AMX] Tomcat Started"
    fi
done