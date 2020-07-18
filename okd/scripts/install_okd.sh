#!/bin/bash
# Aprovisionamiento
# Hardening
# Preparacion de volumenes
# Minimo 8 GB de RAM en los App y el Infra
############ Instalacion del DNS (Servidor DNS) #############

firewall-cmd --permanent --add-port=53/tcp
firewall-cmd --permanent --add-port=53/udp
firewall-cmd --reload

#######################################
#                                     #
#             Runit Bind 9            #
#                                     #
#######################################

BIND_CONTAINER="bind"
BIND_DOMAIN="cs.gadt.amxdigital.net"

mkdir -p /var/containers/$BIND_CONTAINER{/var/named/views/,/var/named/zones/,/etc/named} -p
chown 25:0 -R /var/containers/$BIND_CONTAINER

docker run -itd --name $BIND_CONTAINER \
    -p 53:53/tcp \
    -p 53:53/udp \
    -h $BIND_CONTAINER.$BIND_DOMAIN \
    -v /etc/localtime:/etc/localtime:ro \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /var/containers/$BIND_CONTAINER/var/named/views/:/var/named/views/:z \
    -v /var/containers/$BIND_CONTAINER/var/named/zones/:/var/named/zones/:z \
    -v /var/containers/$BIND_CONTAINER/etc/named:/etc/named:z \
    -e "TZ=America/Mexico_City" \
    dockeregistry.amovildigitalops.com/atomic-rhel7-bind

# views.conf
# view "internal-zone" {
#     match-clients { 10.10.26.0/25; };
#     zone "okd.cs.gadt.amxdigital.net" IN {
#        type master;
#        file "zones/internal/okd.cs.gadt.amxdigital.net";
#      };
#     zone "dcv.cs.gadt.amxdigital.net" IN {
#        type master;
#        file "zones/internal/dcv.cs.gadt.amxdigital.net";
#      };
# };
# view "external-zone" {
#     match-clients { any; };
#     zone "cs.gadt.amxdigital.net" IN {
#        type master;
#        file "zones/external/cs.gadt.amxdigital.net";
#      };
# };

# internal/okd.cs.gadt.amxdigital.net
# $TTL 3600
# @       IN      SOA     okd.cs.gadt.amxdigital.net.  . (
#                 1267456419      ; Serial
#                 10800   ; Refresh
#                 3600    ; Retry
#                 3600    ; Expire
#                 3600)   ; Minimum
#         IN              NS  ns0
#         IN              A   10.10.26.3;
# ns0             IN A            10.10.26.3
# csmast01-1      IN A            10.10.26.4
# cslb01-1        IN A            10.10.26.5
# csinfra01-1     IN A            10.10.26.6
# consola         IN A            10.10.26.6
# csapp01-1       IN A            10.10.26.7
# *.apps          IN A            200.57.183.50

# internal/dcv.cs.gadt.amxdigital.net
# $TTL    3600
# @       IN      SOA     dcv.cs.gadt.amxdigital.net.  . (
#                 1267456420      ; Serial
#                 3600    ; Refresh
#                 3600    ; Retry
#                 3600    ; Expire
#                 3600)   ; Minimum
#         IN              NS  ns1
#         IN              A   10.10.26.3;
# ns1                 IN A            10.10.26.3
# devtechjablab       IN A            10.10.26.3

# external/cs.gadt.amxdigital.net
# $TTL    3600
# @       IN      SOA     cs.gadt.amxdigital.net.  . (
#                 1267456429      ; Serial
#                 10800   ; Refresh
#                 3600    ; Retry
#                 3600    ; Expire
#                 3600)   ; Minimum
#         IN              NS  ns0
#         IN              A   200.57.183.50;
# ns0             IN A            200.57.183.50
# *               IN A            200.57.183.50
# *.apps.okd      IN A            200.57.183.50
############################################################################################
# Preparacion de volumenes
# Creación de usuario Ansible
    ## echo "ansible  ALL=(ALL)      NOPASSWD: ALL" >> /etc/sudoers #(En cada servidor)
# Preparacion de inventario

############################################################################################

### Preparacion de Hosts
ansible-playbook -i 0.inventory-vcloud -b 1.preparing-hosts.yml

### Preparación Lb
ansible-playbook -i 0.inventory-vcloud -b 3.preparing-host-lb.yml
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --permanent --add-port=8443/tcp
firewall-cmd --reload

### Clonar repositorio (Ubicados en el home del usuario Ansible)
git clone -b release-3.11 https://github.com/openshift/openshift-ansible.git ~/openshift-ansible

# Instalar en el nodo Ansible
yum install -y httpd-tools java-1.8.0-openjdk-headless

### Ejecución de playbooks
## Actualizacion de Kernel
ansible -m copy -a "src=kernel-3.10.0-1127.el7.x86_64.rpm  dest=/home/ansible/" -b -i ~/okd/playbooks/0.inventory-vcloud all
ansible -m yum -a "name=/home/ansible/kernel-3.10.0-1127.el7.x86_64.rpm " -b -i ~/okd/playbooks/0.inventory-vcloud all
ansible -a "bash -c 'reboot'" -b -i ~/okd/playbooks/0.inventory-vcloud all
ansible -m ping -b -i ~/okd/playbooks/0.inventory-vcloud all
ansible -a "bash -c 'uname -r'" -b -i ~/okd/playbooks/0.inventory-vcloud all
ansible -m copy -a "src=CentOS-OpenShift-Origin311.repo  dest=/etc/yum.repos.d/CentOS-OpenShift-Origin311.repo owner=root group=root mode='644'" -b -i ~/okd/playbooks/0.inventory-vcloud all
ansible -a "bash -c 'yum clean all'" -b -i ~/okd/playbooks/0.inventory-vcloud all

# Agregar usuario y grupo nobody
ansible -a "bash -c 'echo \"nobody:x:99:\" >> /etc/group'" -i ~/okd/playbooks/0.inventory-vcloud all
ansible -a "bash -c 'echo \"nobody:x:99:99:Nobody:/:/sbin/nologin\" >> /etc/passwd'" -i ~/okd/playbooks/0.inventory-vcloud all
# Prendemos dnsmasq.service
ansible -a "bash -c 'systemctl start dnsmasq.service'" -i ~/okd/playbooks/0.inventory-vcloud -b all
sysctl -w net.ipv4.ip_forward=1
# Instalacion ansible https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/ansible-2.9.7-1.el7.ans.noarch.rpm

# Ejecucion de playbooks
cd ~/openshift-ansible/playbooks
nohup ansible-playbook -i ~/okd/playbooks/0.inventory-vcloud -vvvv openshift-checks/pre-install.yml & # listo
nohup ansible-playbook -i ~/okd/playbooks/0.inventory-vcloud -vvvv openshift-node/bootstrap.yml & # listo
nohup ansible-playbook -i ~/okd/playbooks/0.inventory-vcloud -vvvv openshift-etcd/config.yml & # listo
nohup ansible-playbook -i ~/okd/playbooks/0.inventory-vcloud -vvvv openshift-loadbalancer/config.yml & # listo
nohup ansible-playbook -i ~/okd/playbooks/0.inventory-vcloud -vvvv openshift-master/config.yml & # listo
nohup ansible-playbook -i ~/okd/playbooks/0.inventory-vcloud -vvvv openshift-master/additional_config.yml & # listo
nohup ansible-playbook -i ~/okd/playbooks/0.inventory-vcloud -vvvv openshift-node/join.yml & # listo
nohup ansible-playbook -i ~/okd/playbooks/0.inventory-vcloud -vvvv openshift-hosted/config.yml & # listo
nohup ansible-playbook -i ~/okd/playbooks/0.inventory-vcloud -vvvv openshift-monitoring/config.yml & # listo
nohup ansible-playbook -i ~/okd/playbooks/0.inventory-vcloud -vvvv 

# /home/ansible/openshift-ansible/roles/openshift_logging/tasks/patch_configmap_file.yaml
# Cambiar a true la parte de ansible_become: false
# - local_action: command patch --force --quiet -u {{ local_tmp.stdout }}/configmap_new_file {{ local_tmp.stdout }}/patch.patch
#     vars:
#       ansible_become: false

# Creacion de certificado
certbot certonly --manual -d *.apps.okd.cs.gadt.amxdigital.net -d apps.okd.cs.gadt.amxdigital.net --agree-tos --no-bootstrap --manual-public-ip-logging-ok --preferred-challenges dns-01 --server https://acme-v02.api.letsencrypt.org/directory
# /etc/letsencrypt/live/apps.okd.cs.gadt.amxdigital.net/fullchain.pem
# /etc/letsencrypt/live/apps.okd.cs.gadt.amxdigital.net/privkey.pem

# apps.okd.conf
# server {
#     server_name  *.apps.okd.cs.gadt.amxdigital.net;

#     proxy_max_temp_file_size 0;
#     proxy_buffering off;

#     location / {

#         proxy_pass https://10.10.27.5$request_uri;
#         proxy_set_header        Host           "$host";

#         proxy_ssl_name $host;
#         proxy_ssl_server_name on;
#         proxy_ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
#         proxy_ssl_session_reuse off;
#         proxy_intercept_errors off;
#         proxy_redirect off;
#         proxy_http_version 1.1;
#         proxy_set_header  X-Real-IP  $remote_addr;
#         proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
#         add_header Last-Modified $date_gmt;
#         proxy_set_header Connection keep-alive;
#         add_header Cache-Control 'no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0';
#         if_modified_since off;
#         expires off;
#         etag off;
#         proxy_set_header Upgrade $http_upgrade;
#         proxy_set_header Connection "upgrade";
#         client_max_body_size 0;
#     }

#     location /auth/ {

#         proxy_pass https://10.10.27.5$request_uri;
#         proxy_set_header        Host           "$host";

#         proxy_ssl_name $host;
#         proxy_ssl_server_name on;
#         proxy_ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
#         proxy_ssl_session_reuse off;

#         proxy_redirect off;
#         proxy_http_version 1.1;
#         proxy_set_header Connection keep-alive;
#         proxy_set_header  X-Real-IP  $remote_addr;
#         proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
#         add_header Last-Modified $date_gmt;
#         add_header Cache-Control 'no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0';
#         if_modified_since off;
#         expires off;
#         etag off;
#         client_max_body_size 0;
#     }

#     proxy_hide_header X-Powered-By;
#     proxy_hide_header Server;

#     listen 443 ssl; # managed by Certbot
#     ssl_certificate /etc/letsencrypt/live/apps.okd.cs.gadt.amxdigital.net/fullchain.pem; # managed by Certbot
#     ssl_certificate_key /etc/letsencrypt/live/apps.okd.cs.gadt.amxdigital.net/privkey.pem; # managed by Certbot
#     include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
#     ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
# }
# server {
#     server_name  *.apps.okd.cs.gadt.amxdigital.net;
#     listen 80;
#     return 301 https://$host$request_uri;
# }

## Creacion de router
oc login -u system:admin
oc project openshift-infra
oc adm policy add-scc-to-user hostnetwork -z router
oc adm router openshift-router --replicas=0 --service-account=router
oc set env dc/openshift-router ROUTER_ALLOW_WILDCARD_ROUTES=true
oc scale dc/openshift-router --replicas=1

oc adm policy add-scc-to-user anyuid -z default

oc adm policy add-scc-to-group anyuid system:authenticated