#!/bin/bash

trap "docker_stop" SIGINT SIGTERM

function docker_stop {
        echo "[AMX] Rcv end signal"
        pkill java
}

if [ ! -z "$(ls -A /deployments/config)" ]; then
    echo "[AMX] Directory of Microcks config isn't empty"
    echo "[AMX] Starting Microcks..."
    java -jar /microcks/microcks-0.8.1.jar
    echo "[AMX] Microcks is started"
else
    echo "[AMX] Directory of Microcks is empty"
    cp /root/application.properties /root/logback.xml /deployments/config/
    echo "[AMX] Starting Microcks..."
    java -jar /microcks/microcks-0.8.1.jar
    echo "[AMX] Microcks is started"
fi