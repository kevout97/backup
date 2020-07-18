#!/bin/bash

# Despliegue FreeIpa Server
docker run --name freeipa -ti \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
    --restart unless-stopped \
    --tmpfs /run \
    --tmpfs /tmp \
    -v /var/containers/freeipa/var/lib/ipa-data:/data:z \
    -h ipa.san.gadt.amxdigital.net \
    -p 53:53/udp \
    -p 80:80 \
    -p 443:443 \
    -p 389:389 \
    -p 636:636 \
    -p 88:88 \
    -p 464:464 \
    -p 88:88/udp \
    -p 464:464/udp \
    -p 123:123/udp \
    -p 7389:7389 \
    -p 9443:9443 \
    -p 9444:9444 \
    -p 9445:9445 \
    --add-host ipasat.san.gadt.amxdigital.net:10.23.142.133 \
    dockeregistry.amovildigitalops.com/rhel7-atomic-freeipa:4.6.5

# Despliegue FreeIpa Replica
docker run --name freeipa -ti \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
    --restart unless-stopped \
    --tmpfs /run \
    --tmpfs /tmp \
    -v /var/containers/freeipa/var/lib/ipa-data:/data:Z \
    -h ipasat.san.gadt.amxdigital.net \
    -p 53:53/udp \
    -p 80:80 \
    -p 443:443 \
    -p 636:636 \
    -p 389:389 \
    -p 88:88 \
    -p 464:464 \
    -p 88:88/udp \
    -p 464:464/udp \
    -p 123:123/udp \
    -p 7389:7389 \
    -p 9443:9443 \
    -p 9444:9444 \
    -p 9445:9445 \
    --add-host ipa.san.gadt.amxdigital.net:10.23.142.134 \
    dockeregistry.amovildigitalops.com/rhel7-atomic-freeipa:4.6.5 ipa-replica-install --admin-password=abcd1234 --domain=san.gadt.amxdigital.net --server=ipa.san.gadt.amxdigital.net --realm=SAN.GADT.AMXDIGITAL.NET
