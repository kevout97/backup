#!/bin/bash
#####################################
#                                   #
#         Jicofo Runit              #
#                                   #
#####################################

JICOFO_CONTAINER="jitsi-jicofo"
JICOFO_HOST="localhost"
JICOFO_HOSTNAME="claroconnect.com"
JICOFO_SECRET='xP6fgU#l'
JICOFO_PORT="5347"
JICOFO_AUTH_DOMAIN="auth.claroconnect.com"
JICOFO_AUTH_USER="focus"
JICOFO_AUTH_PASSWORD="fa8DmGQk"
JICOFO_BRIDGE_MUC="JvbBrewery@internal.auth.claroconnect.com"

docker run -itd --name $JICOFO_CONTAINER \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -e "TZ=America/Mexico_City" \
    -e "JICOFO_HOST=$JICOFO_HOST" \
    -e "JICOFO_HOSTNAME=$JICOFO_HOSTNAME" \
    -e "JICOFO_SECRET=$JICOFO_SECRET" \
    -e "JICOFO_PORT=$JICOFO_PORT" \
    -e "JICOFO_AUTH_DOMAIN=$JICOFO_AUTH_DOMAIN" \
    -e "JICOFO_AUTH_USER=$JICOFO_AUTH_USER" \
    -e "JICOFO_AUTH_PASSWORD=$JICOFO_AUTH_PASSWORD" \
    -e "JICOFO_BRIDGE_MUC=$JICOFO_BRIDGE_MUC" \
    docker-source-registry.amxdigital.net/jitsi-jp-jicofo