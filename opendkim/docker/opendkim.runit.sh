#!/bin/

######################################################
#                                                    #
# Runit Opendkim 2.11                                #
#                                                    #
######################################################

OPENDKIM_CONTAINER=opendkim
OPENDKIM_DOMAIN=dkim.amx.gadt.amxdigital.net # Dominio al que se añadira Dkim

docker run -itd --name $OPENDKIM_CONTAINER \
    -v /etc/localtime:/etc/localtime:ro \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -e "TZ=America/Mexico_City" \
    -e "OPENDKIM_DOMAIN=$OPENDKIM_DOMAIN" \
    -p 8891:8891 \
    dockeregistry.amovildigitalops.com/atomic-rhel7-opendkim