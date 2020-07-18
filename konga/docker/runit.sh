#!/bin/bash

# Despliegue de Konga
docker run -itd --name konga \
    --hostname=konga.service \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /var/containers/konga/opt/konga:/opt/konga:z \
    -v /etc/localtime:/etc/localtime:ro \
    -e "TZ=America/Mexico_City" \
    -e "KONGA_DB_ADAPTER=mysql" \
    -e "KONGA_DB_USER=root" \
    -e "KONGA_DB_PASSWORD=abcd1234" \
    -e "KONGA_DB_HOST=mysql" \
    -e "KONGA_DB_PORT=3306" \
    -e "KONGA_DB_DATABASE=konga" \
    -e "KONGA_TOKEN_SECRET=tokenSecret" \
    -e "KONGA_DB_URI=mysql://root:abcd1234@mysql:3306/konga" \
    -p 1337:1337 \
    dockeregistry.amovildigitalops.com/rhel7-atomic-konga
