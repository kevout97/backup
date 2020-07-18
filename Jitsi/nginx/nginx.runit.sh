#!/bin/bash
#######################################################################
#                                                                     #
#                        RUN NGINX CONTAINER                          #
#                                                                     #
#######################################################################
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --reload

# Create base directories
mkdir -p /var/containers/shared/var/www/sites \
              /var/containers/nginx/{var/log/nginx,etc/nginx/vhosts,etc/nginx/conf.d,var/cache/nginx,var/backups,etc/nginx/keys}
# Create soft link
ln -s /var/containers/nginx/var/log/nginx/ /var/log/
# Setup logrotate script
mkdir -p /etc/logrotate.d/

echo 'L3Zhci9sb2cvbmdpbngvKi5sb2cgewogICAgICAgIGRhaWx5CiAgICAgICAgbWlzc2luZ29rCiAgICAgICAgcm90YXRlIDYwCiAgICAgICAgY29tcHJlc3MKICAgICAgICBkZWxheWNvbXByZXNzCiAgICAgICAgbm90aWZlbXB0eQogICAgICAgIGNyZWF0ZSA2NDQKICAgICAgICBzaGFyZWRzY3JpcHRzCiAgICAgICAgcG9zdHJvdGF0ZQogICAgICAgICAgICBuZ2lueCAtcyByZWxvYWQKICAgICAgICBlbmRzY3JpcHQKfQovdmFyL2xvZy9uZ2lueC8qLyoubG9nIHsKICAgICAgICBkYWlseQogICAgICAgIG1pc3NpbmdvawogICAgICAgIHJvdGF0ZSA2MAogICAgICAgIGNvbXByZXNzCiAgICAgICAgZGVsYXljb21wcmVzcwogICAgICAgIG5vdGlmZW1wdHkKICAgICAgICBjcmVhdGUgNjQ0CiAgICAgICAgc2hhcmVkc2NyaXB0cwogICAgICAgIHBvc3Ryb3RhdGUKICAgICAgICAgICAgbmdpbnggLXMgcmVsb2FkCiAgICAgICAgZW5kc2NyaXB0Cn0KCg==' | base64 -w0 -d > /etc/logrotate.d/nginx

docker rm -f nginx
docker run -td --name=nginx -p 80:80 -p 443:443 --privileged=false \
    --volume=/var/containers/shared/var/www/sites:/var/www/sites:z \
    --volume=/var/containers/nginx/var/log/nginx:/var/log/nginx:z \
    --volume=/var/containers/nginx/etc/nginx/vhosts:/etc/nginx/vhosts:z \
    --volume=/var/containers/nginx/etc/nginx/keys:/etc/nginx/keys:z \
    --volume=/var/containers/nginx/etc/nginx/conf.d:/etc/nginx/conf.d:z \
    --volume=/var/containers/nginx/var/cache/nginx:/var/cache/nginx:z  \
    --volume=/var/containers/nginx/var/backups:/var/backups:z \
    --volume=/etc/localtime:/etc/localtime:ro \
    --hostname=nginx.service \
    --ulimit nofile=1024600:1024600 \
    --sysctl net.core.somaxconn=65535 \
    --restart always \
   dockeregistry.amovildigitalops.com/atomic-rhel7-nginx