#!/bin/bash
#####################################
#                                   #
#         Jicofo Runit              #
#                                   #
#####################################

JICOFO_CONTAINER="jicofo"
AUTH_TYPE="internal"
XMPP_DOMAIN="claroconnect.com"
XMPP_AUTH_DOMAIN="auth.claroconnect.com"
XMPP_INTERNAL_MUC_DOMAIN="internal.auth.claroconnect.com"
XMPP_SERVER="claroconnect.com"
JICOFO_COMPONENT_SECRET='xP6fgU#l'
JICOFO_AUTH_USER="focus"
JICOFO_AUTH_PASSWORD="fa8DmGQk"
JVB_BREWERY_MUC="JvbBrewery"
TZ="America/Mexico_City"

mkdir -p /var/containers/$JICOFO_CONTAINER/config
cat<<-EOF > /var/containers/$JICOFO_CONTAINER/config/sip-communicator.properties
org.jitsi.jicofo.BRIDGE_MUC=JvbBrewery@internal.auth.claroconnect.com
EOF

chown 999:1000 -R /var/containers/$JICOFO_CONTAINER

docker run -itd --name $JICOFO_CONTAINER \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /var/containers/$JICOFO_CONTAINER/config:/config:z \
    -e AUTH_TYPE=$AUTH_TYPE \
    -e XMPP_DOMAIN=$XMPP_DOMAIN \
    -e XMPP_AUTH_DOMAIN=$XMPP_AUTH_DOMAIN \
    -e XMPP_INTERNAL_MUC_DOMAIN=$XMPP_INTERNAL_MUC_DOMAIN \
    -e XMPP_SERVER=$XMPP_SERVER \
    -e JICOFO_COMPONENT_SECRET=$JICOFO_COMPONENT_SECRET \
    -e JICOFO_AUTH_USER=$JICOFO_AUTH_USER \
    -e JICOFO_AUTH_PASSWORD=$JICOFO_AUTH_PASSWORD \
    -e JVB_BREWERY_MUC=$JVB_BREWERY_MUC \
    -e TZ=$TZ \
    docker.io/jitsi/jicofo:stable-4548-1