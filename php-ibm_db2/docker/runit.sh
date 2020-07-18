#!/bin/bash

CONTAINER=php72-rc1
instancia=db2amx

mkdir -p    /var/containers/${CONTAINER}/{var/log/php-fpm/,etc/opt/rh/rh-php72/,var/opt/rh/rh-php72/lib/php/session/} \
            /var/containers/shared/var/www/sites/ \
            /var/${CONTAINER}/tmp/ \
            /var/cache/containers/${CONTAINER}/

chown 48 /var/containers/${CONTAINER}/{var/log/php-fpm/,etc/opt/rh/rh-php72/,var/opt/rh/rh-php72/lib/php/session/} /var/${CONTAINER}/tmp/ /var/cache/containers/${CONTAINER}/

# Run container
docker run -td --name=${CONTAINER} --privileged=false \
                    --volume=/var/${CONTAINER}/tmp/:/tmp/:z \
                    --volume=/var/cache/containers/${CONTAINER}/:/var/cache/:z \
                    --volume=/etc/localtime:/etc/localtime:ro \
                    --volume=/usr/share/zoneinfo:/usr/share/zoneinfo:ro \
                    --volume=/var/containers/${CONTAINER}/var/log/php-fpm/:/var/log/php-fpm/:z \
                    --volume=/var/containers/shared/var/www/sites/:/var/www/sites/:ro,z \
                    --volume=/var/containers/${CONTAINER}/var/opt/rh/rh-php72/lib/php/session/:/var/opt/rh/rh-php72/lib/php/session/:z \
                    --hostname=${hostname}-${CONTAINER} \
                    --dns 172.27.140.132 \
                    -e "SESSION_HANDLER=redis" \
                    -e "SESSION_SAVE_PATH=tcp://redis-storage.dev.claroshop.com:6379?auth=@st0rAg3K3Y" \
                    -e "instance_name=$instancia" \
                    -p 9223:9000 \
                    atomic-rhel7-nginx-php-fpm72-ibm
