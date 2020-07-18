# Configuración de volúmenes

Se deben configurar diferentes volúmenes a sus repectivos directorios en los que trabaja OKD 3.11

> En caso de que el disco no este particionado, generamos una nueva partición.

```
fdisk -l #Listamos los discos
fdisk /dev/sdb #Generamos una particion al disco (/dev/sdb es el disco que hemos añadido)
# # n ==> para una nueva particion
# # p ==> Particion primaria
# # 1 ==> Para indicar que es la primera particion
# # (Enter) ==> Para ocupar todo el disco
# # w ==> Guardar y salir
```

> No olvidar desmontar el volumen donde ya se encuentre montado el disco de almacenamiento adicional. (Si aplica)
```sh
# Ejemplo para desmontar el volumen en /disco_2

umount /disco_2
sed -i '/^LABEL=disco_2.*/d' /etc/fstab
```

Crear el physical volume y el volume group que se usarán para los volúmenes lógicos.
```sh
pvcreate -f /dev/sdb1
vgcreate datavg1 /dev/sdb1
```

## Volúmenes para nodos Master/etcd

Para estos servidores se acondicionaros los LVMs de la siguiente manera:

+ /var/lib/openshift 15G
+ /var/lib/etcd 25G
+ /var/lib/docker 150G
+ /var/lib/containers 150G
+ /var/lib/origin 100G
+ /var/log 50G

Ejemplo para crear y montar un volúmen lógico en */var/lib/openshift*

```sh
# /var/lib/openshift 15G
lvcreate -L 15G -n lv_var_lib_openshift datavg1
mkfs.xfs /dev/mapper/datavg1-lv_var_lib_openshift
mkdir -p /var/lib/openshift
mount /dev/mapper/datavg1-lv_var_lib_openshift /var/lib/openshift
tail -n1 /etc/mtab >> /etc/fstab
```
> Para comandos completos ver el script hecho para todos los volúmenes en [lvms_okd_master_etcd.sh](scripts/lvms_okd_master_etcd.sh)

Después de crear y montar todos los lvms, verificar que todo esté correcto y reiniciar la vm.

```sh

lsblk
vgs
cat /etc/fstab

# Revisar a fondo que el proceso se haya hecho correctamente, 
# al finalizar debe realizarse un reboot, si no se hizo bien, 
# se corre el riesgo de que el servidor no vuelva del reinicio.

reboot
```

## Volúmenes para nodos App/Infra y Load Balancer

Para estos servidores se acondicionaros los LVMs de la siguiente manera:

+ /var/lib/openshift 15G
+ /var/lib/docker 150G
+ /var/lib/containers 150G
+ /var/lib/origin 100G
+ /var/log 49G

Ejemplo para crear y montar un volúmen lógico en */var/lib/openshift*

```sh
# /var/lib/openshift 15G
lvcreate -L 15G -n lv_var_lib_openshift datavg1
mkfs.xfs /dev/mapper/datavg1-lv_var_lib_openshift
mkdir -p /var/lib/openshift
mount /dev/mapper/datavg1-lv_var_lib_openshift /var/lib/openshift
tail -n1 /etc/mtab >> /etc/fstab
```
> Para comandos completos ver el script hecho para todos los volúmenes en [lvms_okd_app.sh](scripts/lvms_okd_app.sh)

Después de crear y montar todos los lvms, verificar que todo esté correcto y reiniciar la vm.

```sh

lsblk
vgs
cat /etc/fstab

# Revisar a fondo que el proceso se haya hecho correctamente, 
# al finalizar debe realizarse un reboot, si no se hizo bien, 
# se corre el riesgo de que el servidor no vuelva del reinicio.

reboot
```

## Eliminar LVMs

En caso de necesitar borrar un LVM aquí está un ejemplo.

```sh
lsblk # Para identificar el lvm a borrar, en este caso será lv_var_lib_origin_openshift

umount /var/lib/origin/openshift
lvremove /dev/datavg1/lv_var_lib_origin_openshift

# Verificar liberación del espacio
vgs

## No olvidar eliminar la línea de montaje en /etc/fstab ##
```