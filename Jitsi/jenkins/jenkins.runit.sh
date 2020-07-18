#!/bin/bash
#######################################################################
#                        RUN JENKINS CONTAINER                        #
#######################################################################

JENKINS_TUNEL=50000
JENKINS_HTTP_PORT=8080
JENKINS_CONTAINER="jenkins.jitsi"

firewall-cmd --permanent --add-port=$JENKINS_TUNEL/tcp
firewall-cmd --permanent --add-port=$JENKINS_HTTP_PORT/tcp
firewall-cmd --reload

mkdir -p /var/containers/$JENKINS_CONTAINER/var/jenkins_home
chown 1000:1000 -R /var/containers/$JENKINS_CONTAINER

docker run -tid --name $JENKINS_CONTAINER \
    -h jenkins.videoconferenciaclaro.com \
    -v /var/containers/$JENKINS_CONTAINER/var/jenkins_home:/var/jenkins_home:z \
    -v /etc/localtime:/etc/localtime:ro \
    -p $JENKINS_HTTP_PORT:8080 \
    -p $JENKINS_TUNEL:50000 \
    quay.io/openshift/origin-jenkins:4.2