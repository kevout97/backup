#!/bin/bash
############################################
#                                          #
#           Videobridge Jitsi              #
#                                          #
############################################

JVB_CONTAINER="jvpv3jvb101-1"

XMPP_AUTH_DOMAIN="auth.claroconnect.com"
XMPP_MUC_DOMAIN="muc.claroconnect.com"
XMPP_SERVER="claroconnect.com"
JVB_BREWERY_MUC="JvbBrewery"
JVB_AUTH_USER="jvb"
JVB_AUTH_PASSWORD="JWlc6CDg"
JVB_STUN_SERVERS="meet-jit-si-turnrelay.jitsi.net:443"
JVB_PORT="10000"
JVB_TCP_HARVESTER_DISABLED="false"
JVB_TCP_PORT="4443"
JVB_TCP_MAPPED_PORT="4443"
JVB_ENABLE_APIS="rest,colibri"
JVB_SECRET="JWlc6CDg"
TZ="America/Mexico_City"

mkdir -p /var/containers/${JVB_CONTAINER}/config

cat<<-EOF > /var/containers/$JVB_CONTAINER/config/sip-communicator.properties
org.jitsi.videobridge.rest.jetty.cors.allowedOrigins=*.claroconnect.com
org.jitsi.videobridge.TRUST_BWE=false
org.ice4j.ice.harvest.DISABLE_AWS_HARVESTER=true
org.ice4j.ice.harvest.STUN_MAPPING_HARVESTER_ADDRESSES=meet-jit-si-turnrelay.jitsi.net:443
org.jitsi.videobridge.ENABLE_STATISTICS=true
org.jitsi.videobridge.STATISTICS_TRANSPORT=muc
org.jitsi.videobridge.xmpp.user.shard.HOSTNAME=claroconnect.com
org.jitsi.videobridge.xmpp.user.shard.DOMAIN=auth.claroconnect.com
org.jitsi.videobridge.xmpp.user.shard.USERNAME=jvb
org.jitsi.videobridge.xmpp.user.shard.PASSWORD=JWlc6CDg
org.jitsi.videobridge.xmpp.user.shard.MUC_JIDS=JvbBrewery@internal.auth.claroconnect.com
org.jitsi.videobridge.xmpp.user.shard.MUC_NICKNAME=$JVB_CONTAINER.iris.io
org.jitsi.videobridge.SINGLE_PORT_HARVESTER_PORT=10000
org.jitsi.videobridge.DISABLE_TCP_HARVESTER=false
org.jitsi.videobridge.TCP_HARVESTER_PORT=4443
org.jitsi.videobridge.xmpp.user.shard.DISABLE_CERTIFICATE_VERIFICATION=true
org.jitsi.videobridge.STATISTICS_INTERVAL=5000
EOF

chown 999:1000 -R /var/containers/${JVB_CONTAINER}

docker run -itd --name $JVB_CONTAINER \
  -p $JVB_PORT:$JVB_PORT/udp \
  -p 5000:5000/udp \
  -p $JVB_TCP_PORT:$JVB_TCP_PORT \
  -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
  -v /var/containers/$JVB_CONTAINER/config/sip-communicator.properties:/config/sip-communicator.properties:z \
  -e XMPP_AUTH_DOMAIN=$XMPP_AUTH_DOMAIN \
  -e XMPP_MUC_DOMAIN=$XMPP_MUC_DOMAIN \
  -e XMPP_SERVER=$XMPP_SERVER \
  -e JVB_BREWERY_MUC=$JVB_BREWERY_MUC \
  -e JVB_AUTH_USER=$JVB_AUTH_USER \
  -e JVB_STUN_SERVERS=$JVB_STUN_SERVERS \
  -e JVB_PORT=$JVB_PORT \
  -e JVB_TCP_HARVESTER_DISABLED=$JVB_TCP_HARVESTER_DISABLED \
  -e JVB_TCP_PORT=$JVB_TCP_PORT \
  -e JVB_TCP_MAPPED_PORT=$JVB_TCP_PORT \
  -e JVB_ENABLE_APIS=$JVB_ENABLE_APIS \
  -e JVB_SECRET=$JVB_SECRET \
  -e JVB_AUTH_PASSWORD=$JVB_AUTH_PASSWORD \
  -e TZ:$TZ \
   docker.io/jitsi/jvb:stable-4548-1