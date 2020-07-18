# Ceph

A continuación se describe el proceso para llevar a cabo la configuración y despliegue de un Cluster Ceph conformado por:

* Nodos Monitor
* Nodos OSD
* Nodos Manager

Es importante señalar que un servidor puede cumplir más de una función, es decir, puede ser Monitor, OSD y Manager al mismo tiempo.

## Prerequisitos

* La cantidad mínima de nodos son:
  *  2 nodos Monitor
  *  2 nodos OSD
  *  2 nodos Manager.
* Instalación y configuración de Ansible.
* Requerimientos mínimos de Hardware de cada servidor
  
  | Nodo    | Cores | RAM   | HDD Base | HDD Extra|
  |---------|-------|-------|----------|----------|
  | Monitor |   8   | 16 GB | 50 GB    | 100 GB   |
  | OSD     |   8   | 16 GB | 50 GB    | 1024 GB  |
  | Manager |   8   | 16 GB | 50 GB    | 100 GB   |

* El SO empleado en este despliegue es Rhel 7.
* Inventario Ansible con una sección **[ceph]** en la que se encuentren listados todos los servidores dedicados para Ceph
* Contar con permisos de superusuario en todos los servidores involucrados

**NOTA**: Dicho despliegue sera realizado desde un servidor al cual nos referiremos como Nodo de Control a partir de este momento, dicho servidor no forma parte del Cluster.

**NOTA**: El despliegue sera realizado desde el Nodo de Control con el usuario configurado para Ansible, es importante que dicho usuario no tenga por nombre **ceph**.

**NOTA**: Los discos extras de los servidores dedicados como nodos OSD **NO** deberán contar con ningún tipo de volumen lógico o partición.

## Desarrollo

### Instalación de paquetes

Como primer paso realizamos la instalación cliente de para el despliegue de Ceph en el Nodo de Control.

Para ello configuramos el repo de yum con el archivo [ceph.repo](../ceph/ceph.repo) ubicado en este repositorio.

```bash
sudo cp ../ceph/ceph.repo /etc/yum.repos.d/ceph.repo
```

Limpiamos la caché de yum e instalamos el cliente.

```bash
sudo yum clean all && sudo yum install ceph-deploy -y
```

Para la configuración e instalación de paquetes utilizados en cada nodo haremos uso del playbook [2.preparing-hosts-ceph.yml](../playbooks/2.preparing-hosts-ceph.yml) ubicado en este repositorio.

*Ejecución del playbook*

```bash
ansible-playbook -i [inventario] /opt/okd-devtech/2.preparing-hosts-ceph.yml
```

### Despliegue

Ubicados en el home del usuario para Ansible generamos un directorio para almacenar los archivos de configuración utilizados por Ceph durante el despliegue.

> E.g. Suponemos que el usuario de Ansible tiene el nombre **ansible**

```bash
sudo su ansible
mkdir -p ~/okd-ceph
cd ~/okd-ceph
```

Situados en el directorio creado, hacemos un reconocimiento de los servidores que conformarán el cluster de Ceph y a su vez generamos el archivo de configuración utilizado por la herramienta de despliegue.

```bash
ceph-deploy new [servidor1] [servidor2] [servidor3] ...
```

**NOTA**: Deberá colocarse el fqdn de cada servidor.

E.g.

```bash
ceph-deploy new okdamxceph1-2.okd.amx.gadt.amxdigital.net okdamxceph2-1.okd.amx.gadt.amxdigital.net okdamxceph3-1.okd.amx.gadt.amxdigital.net okdamxceph4-1.okd.amx.gadt.amxdigital.net
```

A continuación instalamos las dependencias faltantes con la herramienta de instalación, a tráves de:

```bash
ceph-deploy install [servidor1] [servidor2] [servidor3] ...
```

**NOTA**: Deberá colocarse el fqdn de cada servidor.

E.g.

```bash
ceph-deploy install okdamxceph1-2.okd.amx.gadt.amxdigital.net okdamxceph2-1.okd.amx.gadt.amxdigital.net okdamxceph3-1.okd.amx.gadt.amxdigital.net okdamxceph4-1.okd.amx.gadt.amxdigital.net
```

A continuación configuramos los servidores dedicados como nodos Monitor.

```bash
ceph-deploy --overwrite-conf mon create [monitor1] [monitor2] [monitor3] ..
ceph-deploy mon create-initial
```

**NOTA**: Deberá colocarse solamente el hostname del servidor.

E.g.

```bash
ceph-deploy --overwrite-conf mon create okdamxceph1-2 okdamxceph2-1 okdamxceph3-1 okdamxceph4-1
ceph-deploy mon create-initial
```

Enseguida copiamos los archivos de configuración creados en el paso anterior con la siguiente instrucción.

```bash
ceph-deploy admin [servidor1] [servidor2] [servidor3] ...
```

**NOTA**: Deberá colocarse el fqdn de cada servidor

E.g.

```bash
ceph-deploy admin okdamxceph1-2.okd.amx.gadt.amxdigital.net okdamxceph2-1.okd.amx.gadt.amxdigital.net okdamxceph3-1.okd.amx.gadt.amxdigital.net okdamxceph4-1.okd.amx.gadt.amxdigital.net
```

Para la configuración de los nodos OSD se realiza con la siguiente sentencia

```bash
ceph-deploy osd create --data [Path del disco extra] [osd1]
ceph-deploy osd create --data [Path del disco extra] [osd2]
ceph-deploy osd create --data [Path del disco extra] [osd3]
...
```

**NOTA**: Deberá colocarse el fqdn de cada servidor

E.g.

```bash
ceph-deploy osd create --data /dev/sdb okdamxceph1-2.okd.amx.gadt.amxdigital.net
ceph-deploy osd create --data /dev/sdb okdamxceph2-1.okd.amx.gadt.amxdigital.net
ceph-deploy osd create --data /dev/sdb okdamxceph3-1.okd.amx.gadt.amxdigital.net
ceph-deploy osd create --data /dev/sdb okdamxceph4-1.okd.amx.gadt.amxdigital.net
```

Finalmente la configuración de los nodos Manager se lleva a cabo con el comando

```bash
ceph-deploy mgr create [Manager1]
ceph-deploy mgr create [Manager2]
```

**NOTA**: Deberá colocarse el fqdn de cada servidor

E.g.

```bash
ceph-deploy mgr create okdamxceph1-2.okd.amx.gadt.amxdigital.net
ceph-deploy mgr create okdamxceph2-1.okd.amx.gadt.amxdigital.net
```

Para verificar el estado del cluster, haremos uso de ansible utilizando la siguiente instrucción:

```bash
ansible -a "ceph health" -i [inventario] -b ceph
```

Teniendo una salida como la siguiente:

```bash
cluster:
  id:     477e46f1-ae41-4e43-9c8f-72c918ab0a20
  health: HEALTH_OK
```