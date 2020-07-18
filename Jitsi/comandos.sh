#!/bin/bash

## Creacion de bind, zona interna y externa
## Instalacion de Ansible


# Actualizacion del kernel
ansible -m yum -a "name=kernel state=latest" -b jitsi

# Hardening
nohup ansible-playbook /opt/jitsi-claro-conect/okd/playbooks/0.5.hardening-hosts.yml -b

# Posthardening
nohup ansible-playbook /opt/jitsi-claro-conect/okd/playbooks/0.5.hardening-hosts.yml -b

# En el nodo de control
yum install -y httpd-tools java-1.8.0-openjdk-headless

# Clonar repo ansible
git clone -b release-3.11 https://github.com/openshift/openshift-ansible.git /opt/openshift-ansible

# 

echo 'W2NlbnRvcy1vcGVuc2hpZnQtb3JpZ2luMzExXQpuYW1lPUNlbnRPUyBPcGVuU2hpZnQgT3JpZ2luCmJhc2V1cmw9aHR0cDovL21pcnJvci5jZW50b3Mub3JnL2NlbnRvcy83L3BhYXMveDg2XzY0L29wZW5zaGlmdC1vcmlnaW4zMTEvCmVuYWJsZWQ9MQpncGdjaGVjaz0wCgpbY2VudG9zLW9wZW5zaGlmdC1vcmlnaW4zMTEtdGVzdGluZ10KbmFtZT1DZW50T1MgT3BlblNoaWZ0IE9yaWdpbiBUZXN0aW5nCmJhc2V1cmw9aHR0cDovL2J1aWxkbG9ncy5jZW50b3Mub3JnL2NlbnRvcy83L3BhYXMveDg2XzY0L29wZW5zaGlmdC1vcmlnaW4zMTEvCmVuYWJsZWQ9MApncGdjaGVjaz0wCgoKW2NlbnRvcy1vcGVuc2hpZnQtb3JpZ2luMzExLWRlYnVnaW5mb10KbmFtZT1DZW50T1MgT3BlblNoaWZ0IE9yaWdpbiBEZWJ1Z0luZm8KYmFzZXVybD1odHRwOi8vZGVidWdpbmZvLmNlbnRvcy5vcmcvY2VudG9zLzcvcGFhcy94ODZfNjQvCmVuYWJsZWQ9MApncGdjaGVjaz0wCgpbY2VudG9zLW9wZW5zaGlmdC1vcmlnaW4zMTEtc291cmNlXQpuYW1lPUNlbnRPUyBPcGVuU2hpZnQgT3JpZ2luIFNvdXJjZQpiYXNldXJsPWh0dHA6Ly92YXVsdC5jZW50b3Mub3JnL2NlbnRvcy83L3BhYXMvU291cmNlL29wZW5zaGlmdC1vcmlnaW4zMTEvCmVuYWJsZWQ9MApncGdjaGVjaz0wCgo=' | base64 -d > CentOS-OpenShift-Origin311.repo
ansible -m copy -a "src=CentOS-OpenShift-Origin311.repo  dest=/etc/yum.repos.d/CentOS-OpenShift-Origin311.repo owner=root group=root mode='644'" -b -i /opt/okd-devtech/playbooks/0.inventory all
ansible -a "bash -c 'yum clean all'" -b -i /opt/jitsi-claro-conect/okd/playbooks/0.inventory all
rm -f CentOS-OpenShift-Origin311.repo


############################
## Despliegue de jitsi

### Creacion de base de datos y usuario para jitsi en mongo
use jitsi-iam
db.createUser(
   {
     user: "jitsi-user",
     pwd: "cdsGN9Bd9CnCQ49mDL",
     roles: [ "readWrite", "dbAdmin" ]
   }
)

use admin
db.dropUser("jitsi-user")

use admin
db.createUser(
  {
    user: "jitsi-user",
    pwd: "cdsGN9Bd9CnCQ49mDL",
    roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
  }
)

use jitsi-iam
db.createUser(
  {
    user: "jitsi-user",
    pwd: "cdsGN9Bd9CnCQ49mDL",
    roles: [ { role: "dbAdmin", db: "jitsi" } ]
  }
)

db.createUser({ user: "jitsi-user", pwd: "cdsGN9Bd9CnCQ49mDL", roles: [ { role: "dbOwner", db: "jitsiiam" } ]})

### En el proyecto de okd
oc adm policy add-scc-to-user hostaccess -z default