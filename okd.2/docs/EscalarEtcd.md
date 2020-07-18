# Escalar Etcd

## Prerequisitos

* Cluster OKD 3.11
* Haber clonado el repositorio [OKD AMX](https://infracode.amxdigital.net/desarrollo-tecnologico/okd/tree/master) en /opt/okd-devtech.
* Clonar el repositorio oficial de OKD en /opt/openshift-ansible ([OKD 3.11](https://github.com/openshift/openshift-ansible)).
* DNS correctamente configurado con el mismo hostname en cada vm cumpliendo con un FQDN.
* Paquetes necesarios en nodo de control.
* Usuario ansible en todos los nodos del cluster, incluyendo los nuevos nodos.
* Inventario con el que se desplego el cluster ([Inventario](../playbooks/0.inventory))
* Setup completo de volúmenes para el nuevo nodo.

## Desarrollo

> La ejecución de cada uno de los comandos aquí mostrados, deberá realizarse en el Nodo de Control.

Modificamos el inventario con el cual se realizó el despliegue de OKD:

+ Generamos una nuevo grupo al que denominaremos **new_etcd** con el fqdn de los nuevos nodos Etcd.
+ Agregamos al grupo **new_etcd** dentro del del grupo **[OSEv3:children]**

E.g.
```
[OSEv3:children]
...
etcd
new_etcd
...
...
[new_etcd]
etcdokd02.okd.cs.gadt.amxdigital.net
...
```

Ejecutamos el playbook que prepara los nodos, instalando los paquetes necesarios y configurando puertos entre otras cosas.

```
ansible-playbook -i <new_inventory> /opt/okd-devtech/playbooks/1.preparing-hosts.yml --extra-vars "variable_host=new_etcd"
```

Preparamos los ConfigMap para que el nuevo nodo sea reconocido como parte del Cluster.

```
cd /opt/openshift-ansible
ansible-playbook -vvvv -i <new_inventory> playbooks/openshift-master/openshift_node_group.yml
```

Escalamos el cluster de Etcd.

```
cd /opt/openshift-ansible
ansible-playbook -vvvv -i <new_inventory> playbooks/openshift-etcd/scaleup.yml
```

Verificamos que se haya escalado de manera correcta.

> Dentro de uno de los nuevos nodos Etcd.

> Sustituir la línea https://etcd01.okd:2379,https://etcd02.okd:2379, colocando separados por una coma, el FQDN de todos los Nodos Etcd que conforman el cluster.
```
etcdctl -C \
  https://etcd01.okd:2379,https://etcd02.okd:2379 \
  --ca-file=/etc/etcd/ca.crt \
  --cert-file=/etc/etcd/server.crt \
  --key-file=/etc/etcd/server.key cluster-health
```

Obetendremos una salida como la siguiente.

```
member dd2dff7d7741ce2a is healthy: got healthy result from https://10.10.27.10:2379
member f53d8f065c1d0757 is healthy: got healthy result from https://10.10.27.4:2379
cluster is healthy
```

## Issues

**Problema**

Si el proceso de escalado presentó un error durante la ejecución del Playbook **playbooks/openshift-etcd/scaleup.yml** evitando que se agregara el nuevo nodo Etcd asi como los contenedores de Etcd, Api y Consola se caen, es importante no entrar en panico y restaurar el quorum.

**Solución**

Consultar [Restaurar Quorum](ResetQuorum.md)


**Problema**

Si se presenta un error como el siguiente en alguno de los Pods de Etcd.

```
rpc error: code = 2 desc = oci runtime error: exec failed: container_linux.go:235: starting container process caused "exec: \"/bin/sh\": stat /bin/sh: no such file or directory"
```

Se debe a un error de la imagen, eventualmente este error puede repercutir al momento de escalar el cluster, ya que los Pods de Etcd jamas iniciarán despues de un reinicio que uno de los Playbooks realiza.

**Solución**

Identificar donde esta desplegado ese Pod.

Descargar una version mas reciente de la imagen con la que se despliega el Pod, por defecto lo hace con **quay.io/coreos/etcd:v3.2.26** recomendamos descargar **quay.io/coreos/etcd:v3.2.27**

```
docker pull quay.io/coreos/etcd:v3.2.27
```

Eliminar la imagen anterior

```
docker rmi -f quay.io/coreos/etcd:v3.2.26
```

Tagear la nueva imagen con la version de la anterior.

```
docker tag quay.io/coreos/etcd:v3.2.27 quay.io/coreos/etcd:v3.2.26
```

Identificar el contenedor de Etcd y eliminarlo.

Esto permitirá que el nuevo contenedor de Etcd se despliegue utilizando la nueva versión de la imagen.