#!/bin/bash
#############################################
#                                           #
#               Runit Nexus 3               #
#                                           #
#############################################

firewall-cmd --permanent --add-port=8080-8089/tcp
firewall-cmd --reload

mkdir -p /var/containers/nexus/opt/sonatype/app/sonatype-work/nexus3 
chown 1001:1001 /var/containers/nexus/opt/sonatype/app/sonatype-work/nexus3 -R 

docker run -td --hostname=nexus.service --privileged=true  --name nexus-3 \
    --cap-add=IPC_OWNER \
    -p 8080-8090:8080-8090 \
    --health-cmd='/sbin/docker-health-check.sh' \
    --health-interval=10s \
    --restart unless-stopped \
    -v /etc/localtime:/etc/localtime:ro \
    -v /var/containers/nexus/opt/sonatype/app/sonatype-work/nexus3:/opt/sonatype/app/sonatype-work/nexus3:z \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -e TZ=America/Mexico_City \
    -e "NEXUS_XMS=512M" \
    -e "NEXUS_XMX=2g" \
    -e "NEXUS_MAX_DIRECTORY_MEMORY_SIZE=2g" \
    -e "NEXUS_PREFER_IPV4=true" \
    -e "NEXUS_HTTP_PORT=8080" \
    docker-source-registry.amxdigital.net/rhel7-atomic-nexus3.19:v2