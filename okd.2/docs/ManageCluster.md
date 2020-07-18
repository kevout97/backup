# Manejo de cluster OKD

## Agregar nodo app o infra

### Prerrequisitos

* Vm con requerimientos básicos
  * 2 vcores + 4GB RAM
* Editar dns para volver alcanzable este nodo entre todo el cluster por FQDN
* 50GB de disco con los volúmenes configurados (Mínimo)
* Usuario Ansible
* Playbook para hardening ([0.5.hardening-hosts.yml](../playbooks/0.5.hardening-hosts.yml))
* Playbook para preparar hosts ([1.preparing-hosts.yml](../playbooks/1.preparing-hosts.yml))
* Kernel actualizado

### Desarrollo

Actualizar el inventario con el nuevo nodo app o infra, este nuevo nodo debe agregarse en un nuevo grupo provisional que se llamará ***new_nodes***.

Debe ser agregado al bloque children de OSEv3 también. (Cuidar el tipo de nodo según sea el caso: *node-config-compute* o *node-config-infra*).

> Si aplica gregar también al grupo [app]

```txt
[OSEv3:children]
masters
etcd
nodes
lb
new_nodes

........
........
........
........

[app]
okdapp01.okd.cs.gadt.amxdigital.net
<FQDN nuevo nodo app>

[new_nodes]
<FQDN nuevo nodo> openshift_node_group_name='node-config-compute'
```

Confirmar que ansible alcanza el nuevo nodo.

```sh
ansible -m ping -b -i /opt/okd-devtech/playbooks/0.inventory-vcloud all
```

Escalar el nodo.
> Importante correr los playbooks desde el directorio /openshift-ansible

```sh
cd /opt/openshift-ansible
ansible-playbook -vvvv -i /opt/okd-devtech/playbooks/0.inventory-vcloud-scaleup playbooks/openshift-master/openshift_node_group.yml
ansible-playbook -vvvv -i /opt/okd-devtech/playbooks/0.inventory-vcloud-scaleup playbooks/openshift-node/scaleup.yml
```

Verificar que el nodo se agregó de manera correcta. Desde el un nodo master:

```sh
oc get nodes
oc get pods --all-namespaces
```

Etiquetar el nuevo nodo copmo parte del proyecto logging

```sh
oc label node/<FQDN nuevo nodo> logging-infra-fluentd=true
```

### Issues conocidos

**Problema**

* ```bash 
  start_network.go:106] could not start DNS, unable to read config file: open /etc/origin/node/resolv.conf: no such file or directory
  ```

**Solución**

Si existe el error en el levantamiento del pod sdn del nuevo nodo, por no encontrar el dns, resolver con el siguiente comando, ejecutado desde el Nodo de Control, para agregar el dns al nodo:

```sh
ansible -a "bash -c 'echo \"nameserver <dns ip>\" > /etc/origin/node/resolv.conf'" -i /opt/okd-devtech/playbooks/0.inventory-vcloud-scaleup new_nodes
```

Donde:

**dns ip**: Es la Ip del Dns que fue configurado cuando se llevo a cabo el despliegue de OKD. [Setup DNS para OKD](DNS.md)

## Agregar nodo master

### Prerrequisitos

* Vm con requerimientos básicos
  * 2 vcores + 4GB RAM
* Editar dns para volver alcanzable este nodo entre todo el cluster por FQDN
* 50GB de disco con los volúmenes configurados (Mínimo)
* Usuario Ansible
* Playbook para hardening ([0.5.hardening-hosts.yml](../playbooks/0.5.hardening-hosts.yml))
* Playbook para preparar hosts ([1.preparing-hosts.yml](../playbooks/1.preparing-hosts.yml))
* Kernel actualizado

### Desarrollo

Actualizar el inventario con el nuevo nodo master, este nuevo nodo debe agregarse en un nuevo grupo provisional que se llamará ***new_masters*** y a otro nuevo grupo ***new_nodes***.

Debe ser agregado al bloque children de OSEv3 también. (Cuidar el tipo de nodo : *openshift_node_group_name='node-config-master'*).

```txt
[OSEv3:children]
masters
etcd
nodes
lb
new_nodes
new_masters

........
........
........
........

[new_masters]
<FQDN nuevo master> openshift_node_group_name='node-config-master'

[new_nodes]
<FQDN nuevo master> openshift_node_group_name='node-config-master'
```

Confirmar que ansible alcanza el nuevo nodo.

```sh
ansible -m ping -b -i /opt/okd-devtech/playbooks/0.inventory-vcloud all
```

Escalar el nodo.
> Importante correr los playbooks desde el directorio /openshift-ansible

```sh
cd /opt/openshift-ansible
ansible-playbook -vvvv -i /opt/okd-devtech/playbooks/0.inventory-vcloud-scaleup playbooks/openshift-master/openshift_node_group.yml
ansible-playbook -vvvv -i /opt/okd-devtech/playbooks/0.inventory-vcloud-scaleup playbooks/openshift-master/scaleup.yml
```

Verificar que el nodo se agregó de manera correcta. Desde el un nodo master:

```sh
oc get nodes
oc get pods --all-namespaces
```

Etiquetar el nuevo nodo copmo parte del proyecto logging

```sh
oc label node/<FQDN nuevo master> logging-infra-fluentd=true
```

### Issues conocidos

**Problema**

+ ```bash 
  start_network.go:106] could not start DNS, unable to read config file: open /etc/origin/node/resolv.conf: no such file or directory
  ```

**Solución**

Si existe el error en el levantamiento del pod sdn del nuevo nodo, por no encontrar el dns, resolver con el siguiente comando, ejecutado desde el Nodo de Control, para agregar el dns al nodo:

```sh
ansible -a "bash -c 'echo \"nameserver <dns ip>\" > /etc/origin/node/resolv.conf'" -i /opt/okd-devtech/playbooks/0.inventory-vcloud-scaleup new_nodes
```

Donde:

**dns ip**: Es la Ip del Dns que fue configurado cuando se llevo a cabo el despliegue de OKD. [Setup DNS para OKD](DNS.md)

**Problema**

+ ```bash
  "msg": "The task includes an option with an undefined variable. The error was: 'openshift_is_atomic' is undefined\n\nThe error appears to be in '/home/ansible/openshift-ansible/playbooks/init/basic_facts.yml': line 102, column 5, but may\nbe elsewhere in the file depending on the exact syntax problem.\n\nThe offending line appears to be:\n\n\n
  ```

**Solución**

Al momento de ejecutar el playbook que realiza un copy del archivo de configuración que define la estructura del cluster de OKD (**playbooks/openshift-master/openshift_node_group.yml**) se muestra el error anterior, basta con agregar la siguiente línea al inventario.

```bash
openshift_is_atomic=false
```

> E.g El inventario deberá verse asi

```txt
[OSEv3:children]
masters
etcd
nodes
lb
new_nodes
new_masters

[OSEv3:vars]
# General Cluster Variables
## Usuario de ansible
ansible_ssh_user=ansible

## Permitimos que los comandos se ejecuten con 'sudo'
ansible_become=true
........
........
........
........
openshift_is_atomic=false

[all]
okdmast01.okd.cs.gadt.amxdigital.net
okdlb01.okd.cs.gadt.amxdigital.net
okdinfra01.okd.cs.gadt.amxdigital.net

........
........
........
........
```


## Eliminar un Nodo del cluster

> Los siguientes comandos deberán ser ejecutados desde un Nodo Master.

Con permisos de superusuario nos logueamos dentro del cluster de OKD.

```bash
oc login -u system:admin
```

Listamos los nodos que actualmente conforman el cluster

```bash
oc get nodes
```

Primero evacuamos los pods que puedan estar dentro del Nodo que deseamos eliminar.

```bash
oc adm drain <Nombre del nodo> --force=true --ignore-daemonsets
```

Eliminamos el nodo del cluster

```bash
oc delete node <Nombre del nodo>
```