#!/bin/bash
#######################################################################
#                        RUN TOMCAT CONTAINER                          #
#######################################################################

# Create base directories
TOMCAT_VERSION=9.0.27
TOMCAT_CONTAINER=tomcat

mkdir -p /var/containers/tomcat/usr/local/apache-tomcat-$TOMCAT_VERSION/{logs,webapps}
chown 9027:0 -R /var/containers/tomcat/usr/local/apache-tomcat-$TOMCAT_VERSION/{logs,webapps}

docker rm -f $TOMCAT_CONTAINER
docker run -td --name=$TOMCAT_CONTAINER \
    -p 6565:8080 \
    --privileged=false \
    --health-cmd='/sbin/docker-health-check.sh' \
    --health-interval=10s \
    --restart unless-stopped \
    -v /var/containers/shared/var/www/sites/:/var/www/sites/:z \
    -v /var/containers/tomcat/usr/local/apache-tomcat-$TOMCAT_VERSION/logs/:/usr/local/apache-tomcat-$TOMCAT_VERSION/logs/:z \
    -v /var/containers/tomcat/usr/local/apache-tomcat-$TOMCAT_VERSION/webapps:/usr/local/apache-tomcat-$TOMCAT_VERSION/webapps:z \
    -v /etc/localtime:/etc/localtime:ro \
    -e "TOMCAT_USER_GUI=tomcat" \
    -e "TOMCAT_PASSWORD_GUI=abcd1234" \
    -e "MAX_FILE_SIZE=209715200" \
    -e "CONNECTION_TIMEOUT=-1" \
    --hostname=$TOMCAT_CONTAINER.service \
    dockeregistry.amovildigitalops.com/rhel7-atomic-tomcat:9.0.27