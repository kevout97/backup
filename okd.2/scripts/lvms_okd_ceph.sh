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

# /var/lib/ceph 1T
lvcreate -l 100%FREE -n lv_var_lib_ceph datavg1
mkfs.xfs /dev/mapper/datavg1-lv_var_lib_ceph
mkdir -p /var/lib/ceph
mount /dev/mapper/datavg1-lv_var_lib_ceph /var/lib/ceph
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
