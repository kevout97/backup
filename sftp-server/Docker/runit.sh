#!/bin/bash

###########################################################
#                                                         #
#                   RUNIT SFTP SERVICE                    #
#                                                         #
###########################################################
rm -rf /var/containers/sftp

docker rm -f sftp

mkdir -p /var/containers/sftp/var/share

docker run -d --name sftp -p 2222:22 \
    -v /var/containers/sftp/var/share:/var/share:z \
    -e "SFTP_DIRECTORY=/var/share" \
    -e "SFTP_USER=usuario" \
    -e "SFTP_USER_KEY=<llave-publica>" \
    rhel7-atomic-sftp