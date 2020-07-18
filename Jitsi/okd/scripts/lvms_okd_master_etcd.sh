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

# Cores  RAM  HDD
#   8    16   150

LVM_SIZE_VAR_LIB_ETCD="10G"
LVM_SIZE_VAR_LIB_OPENSHIFT="5G"
LVM_SIZE_VAR_LIB_DOCKER="50G"
LVM_SIZE_VAR_LIB_CONTAINERS="50G"
LVM_SIZE_VAR_LIB_ORIGIN="15G"
LVM_SIZE_VAR_LOG="20G"

pvcreate -f /dev/sdb1
vgcreate datavg1 /dev/sdb1

lvcreate -L $LVM_SIZE_VAR_LIB_ETCD -n lv_var_lib_etcd datavg1
mkfs.xfs /dev/mapper/datavg1-lv_var_lib_etcd
mkdir -p /var/lib/etcd
mount /dev/mapper/datavg1-lv_var_lib_etcd /var/lib/etcd
tail -n1 /etc/mtab >> /etc/fstab

lvcreate -L $LVM_SIZE_VAR_LIB_OPENSHIFT -n lv_var_lib_openshift datavg1
mkfs.xfs /dev/mapper/datavg1-lv_var_lib_openshift
mkdir -p /var/lib/openshift
mount /dev/mapper/datavg1-lv_var_lib_openshift /var/lib/openshift
tail -n1 /etc/mtab >> /etc/fstab

lvcreate -L $LVM_SIZE_VAR_LIB_DOCKER -n lv_var_lib_docker datavg1
mkfs.xfs /dev/mapper/datavg1-lv_var_lib_docker
mkdir -p /var/lib/docker
mount /dev/mapper/datavg1-lv_var_lib_docker /var/lib/docker
tail -n1 /etc/mtab >> /etc/fstab

lvcreate -L $LVM_SIZE_VAR_LIB_CONTAINERS -n lv_var_lib_containers datavg1
mkfs.xfs /dev/mapper/datavg1-lv_var_lib_containers
mkdir -p /var/lib/containers
mount /dev/mapper/datavg1-lv_var_lib_containers /var/lib/containers
tail -n1 /etc/mtab >> /etc/fstab

lvcreate -L $LVM_SIZE_VAR_LIB_ORIGIN -n lv_var_lib_origin datavg1
mkfs.xfs /dev/mapper/datavg1-lv_var_lib_origin
mkdir -p /var/lib/origin
mount /dev/mapper/datavg1-lv_var_lib_origin /var/lib/origin
tail -n1 /etc/mtab >> /etc/fstab

lvcreate -l 100%FREE -n lv_var_log datavg1
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