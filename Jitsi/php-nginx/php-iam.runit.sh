#!/bin/bash
######################################
#                                    #
#           Php Iam Jitsi            #
#                                    #
######################################

PHP_IAM_CONTAINER="php-iam-jitsi"

mkdir -p /var/containers/$PHP_IAM_CONTAINER/{etc/nginx/,usr/share/}

docker run -itd --name $PHP_IAM_CONTAINER \
    -p 80:80 \
    -p 443:443 \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /var/containers/$PHP_IAM_CONTAINER/etc/nginx/conf.d/iam.conf:/etc/nginx/conf.d/iam.conf:z \
    -v /var/containers/$PHP_IAM_CONTAINER/etc/nginx/conf.d/iam.conf:/etc/nginx/conf.d/iam.conf:z \
    -v /var/containers/$PHP_IAM_CONTAINER/etc/nginx/conf.d/iam.conf:/etc/nginx/conf.d/iam.conf:z \
    -e "TZ=America/Mexico_City" \
    docker-source-registry.amxdigital.net/jitsi-php-iam

#!/bin/bash

CONTAINER=php-fpm70-r1

mkdir -p /var/containers/${CONTAINER}/{var/log/php-fpm,etc/opt/rh/rh-php70,var/opt/rh/rh-php70/lib/php/session} /var/containers/shared/var/www/sites/ /tmp/containers/php70-sanborns /var/cache/containers/php70-sanborns

docker rm -f ${CONTAINER}
# Run container
docker run -td --name=${CONTAINER} --privileged=false \
                    --memory=2048M \
                    --volume=/tmp/php70-sanborns:/tmp:z \
                    --volume=/var/cache/containers/php70-sanborns:/var/cache/:z \
                    --volume=/var/containers/${CONTAINER}/var/log/php-fpm/:/var/log/php-fpm/:z \
                    --volume=/var/containers/${CONTAINER}/etc/opt/rh/rh-php70/php-fpm.d/:/etc/opt/rh/rh-php70/php-fpm.d/:z \
                    --volume=/var/containers/shared/var/www/sites/:/var/www/sites/:z \
                    --volume=/var/containers/${CONTAINER}/var/opt/rh/rh-php70/lib/php/session/:/var/opt/rh/rh-php70/lib/php/session/:z \
                    --volume=/etc/localtime:/etc/localtime:ro \
                    --dns 8.8.8.8 \
                    --hostname=${CONTAINER} \
                    -e "SESSION_HANDLER=redis" \
                    -e "SESSION_SAVE_PATH=tcp://redis-storage.amx-services.io:6379" \
                    dockeregistry.amovildigitalops.com/atomic-rhel7-php-fpm70