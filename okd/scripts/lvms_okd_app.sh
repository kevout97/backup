#!/bin/bash

# Script dedicado a crear los volúmenes lógicos necesarios para OKD sobre nube Triara.
# En extremo manual, ajustar nombre de montaje según el disco (disco_2, disco_3, etc.)
# Ajustar tamaño de volúmenes según necesidades. 

# En caso de que el disco no este particionado, generamos una nueva partición
# fdisk -l #Listamos los discos
# fdisk /dev/sdc #Generamos una particion al disco (/dev/sdc es el disco que hemos añadido)
# # n ==> para una nueva particion
# # p ==> Particion primaria
# # 1 ==> Para indicar que es la primera particion
# # (Enter) ==> Para ocupar todo el disco
# # w ==> Guardar y salir

umount /disco_2
sed -i '/^LABEL=disco_2.*/d' /etc/fstab
pvcreate -f /dev/sdb1
vgcreate datavg1 /dev/sdb1

# /var/lib/openshift 15G
lvcreate -L 20G -n lv_var_lib_openshift datavg1
mkfs.xfs /dev/mapper/datavg1-lv_var_lib_openshift
mkdir -p /var/lib/openshift
mount /dev/mapper/datavg1-lv_var_lib_openshift /var/lib/openshift
tail -n1 /etc/mtab >> /etc/fstab

# /var/lib/docker 150G
lvcreate -L 165G -n lv_var_lib_docker datavg1
mkfs.xfs /dev/mapper/datavg1-lv_var_lib_docker
mkdir -p /var/lib/docker
mount /dev/mapper/datavg1-lv_var_lib_docker /var/lib/docker
tail -n1 /etc/mtab >> /etc/fstab

# /var/lib/containers 150G
lvcreate -L 165G -n lv_var_lib_containers datavg1
mkfs.xfs /dev/mapper/datavg1-lv_var_lib_containers
mkdir -p /var/lib/containers
mount /dev/mapper/datavg1-lv_var_lib_containers /var/lib/containers
tail -n1 /etc/mtab >> /etc/fstab

# /var/lib/origin 100G
lvcreate -L 100G -n lv_var_lib_origin datavg1
mkfs.xfs /dev/mapper/datavg1-lv_var_lib_origin
mkdir -p /var/lib/origin
mount /dev/mapper/datavg1-lv_var_lib_origin /var/lib/origin
tail -n1 /etc/mtab >> /etc/fstab

# /var/log 49G
lvcreate -L 49G -n lv_var_log datavg1
mkfs.xfs /dev/mapper/datavg1-lv_var_log
mkdir -p /var/log
mount /dev/mapper/datavg1-lv_var_log /var/log
tail -n1 /etc/mtab >> /etc/fstab

lsblk
vgs
cat /etc/fstab

# Revisar a fondo que el proceso se haya hecho correctamente, 
# al finalizar debe realizarse un reboot, si no se hizo bien, 
# se corre el riesgo de que el servidor no vuelva del reinicio.
#reboot


## Borrar un lvm 
# lsblk
# umount /var/lib/origin/openshift.local.volumes
# lvremove /dev/datavg1/lv_var_lib_origin_openshiftlocalvolumes
## Verificar liberación del espacio
# vgs
## No olvidar eliminar la línea de montaje en /etc/fstab
