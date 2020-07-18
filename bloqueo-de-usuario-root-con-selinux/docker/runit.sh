#!/bin/bash

docker run -itd --privileged --name monitoring \
    --health-cmd='/sbin/docker-health-check.sh' \
    --health-interval=10s \
    --restart unless-stopped \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -v /var/containers/private1:/private1:z \
    -v /var/containers/private2:/private2:z \
    -e "TZ=America/Mexico_City" \
    -e "MONITORING_RSYSLOG_HOST=10.23.143.8" \
    -e "MONITORING_RSYSLOG_PORT=515" \
    -e "MONITORING_RSYSLOG_PROTOCOL=UDP" \
    -e "MONITORING_DIRECTORIES=/private1;/private2" \
    dockeregistry.amovildigitalops.com/atomic-rhel7-monitoring-volumen