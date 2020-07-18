#!/bin/bash
## NOTA: Todos los comandos deberan ejecutarse con el usuario, cephdeploy, configurado en playbook 2.preparing-hosts-ceph.yml,

## NOTA: Verificar que el archivo /etc/resolv.conf en la linea search cuente con el dominio que completa el fqdn
## para este depliegue dicho dominio es "okd.amx.gadt.amxdigital.net"

## Importante: el hostname de los servidores debera ser el fqdn asociado a cada uno y en minusculas, para este
## despliegue los servidores tienen el hostname:
# okdamxceph1-2.okd.amx.gadt.amxdigital.net
# okdamxceph2-1.okd.amx.gadt.amxdigital.net
# okdamxceph3-1.okd.amx.gadt.amxdigital.net
# okdamxceph4-1.okd.amx.gadt.amxdigital.net

## Creacion de directorio donde se almacenaran los archivos generados por el instalador de ceph
mkdir -p ~/okd-ceph

## Nos ubicamos en el directorio creado anteriormente
cd ~/okd-ceph

## Creacion de monitores
### Este comando hace un reconocimiento de los nodos que seran monitores y genera el archivo ceph.conf
ceph-deploy new okdamxceph1-2.okd.amx.gadt.amxdigital.net okdamxceph2-1.okd.amx.gadt.amxdigital.net okdamxceph3-1.okd.amx.gadt.amxdigital.net okdamxceph4-1.okd.amx.gadt.amxdigital.net

## Instalacion de paquetes en cada nodo
ceph-deploy install okdamxceph1-2.okd.amx.gadt.amxdigital.net okdamxceph2-1.okd.amx.gadt.amxdigital.net okdamxceph3-1.okd.amx.gadt.amxdigital.net okdamxceph4-1.okd.amx.gadt.amxdigital.net

## Creacion de nodos nomitors
ceph-deploy mon create-initial

## Copiamos los archivos de configuracion
ceph-deploy admin okdamxceph1-2.okd.amx.gadt.amxdigital.net okdamxceph2-1.okd.amx.gadt.amxdigital.net okdamxceph3-1.okd.amx.gadt.amxdigital.net okdamxceph4-1.okd.amx.gadt.amxdigital.net

## Configuracion de los discos
## Para este despliegue cada sevidor cuenta con un disco llamado /dev/sdb, dicho disco se encuentra totalmente virgen,
## sin particiones o volumenes logicos
ceph-deploy osd create --data /dev/sdb okdamxceph1-2.okd.amx.gadt.amxdigital.net
ceph-deploy osd create --data /dev/sdb okdamxceph2-1.okd.amx.gadt.amxdigital.net
ceph-deploy osd create --data /dev/sdb okdamxceph3-1.okd.amx.gadt.amxdigital.net
ceph-deploy osd create --data /dev/sdb okdamxceph4-1.okd.amx.gadt.amxdigital.net

## Creacion de nodos manager
ceph-deploy mgr create okdamxceph1-2.okd.amx.gadt.amxdigital.net
ceph-deploy mgr create okdamxceph2-1.okd.amx.gadt.amxdigital.net

### Los siguientes comandos no son parte de la creacion del cluster, ademas de que son realizados con la
### herramienta Ansible
## Reinicio del cluster
ansible -a "systemctl stop ceph\*.service ceph\*.target" -i /opt/okd/playbooks/0.inventory -b ceph
ansible -a "systemctl start ceph.target" -i /opt/okd/playbooks/0.inventory -b ceph
ansible -a "systemctl status ceph\*.service ceph\*.target" -i /opt/okd/playbooks/0.inventory -b ceph

## Verificamos el estado del cluster
ansible -a "ceph health" -i /opt/okd/playbooks/0.inventory -b ceph

## Eliminar Ceph (Ejecutar desde el nodo, usuario y directorio donde se ejecutaron los comandos para realizar el despliegue)
# cd ~/okd-ceph
# ceph-deploy purge okdamxceph1-2.okd.amx.gadt.amxdigital.net okdamxceph2-1.okd.amx.gadt.amxdigital.net okdamxceph3-1.okd.amx.gadt.amxdigital.net okdamxceph4-1.okd.amx.gadt.amxdigital.net
# ceph-deploy purgedata okdamxceph1-2.okd.amx.gadt.amxdigital.net okdamxceph2-1.okd.amx.gadt.amxdigital.net okdamxceph3-1.okd.amx.gadt.amxdigital.net okdamxceph4-1.okd.amx.gadt.amxdigital.net
# ceph-deploy forgetkeys
# rm -rf ceph*