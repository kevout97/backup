# Restauración Etcd Quorum

El siguiente proceso aplica cuando el Quorum (Número minimo de miembros que deben conformar el cluster) ha sido modificado y alguno de los miembros del cluster de Ectd se ha caido.


Regularmente esto se presenta cuando se intenta escalar el cluster de Etcd y ocurren problemas durante el proceso.

## Requisitos

* Ansible
* Cluster de Etcd en Pods.
* Se asume que el inventario de Ansible cuenta con la sección [Etcd]
* Se asume que este repositorio esta clonado en /opt/okd-devtech

## Desarrollo

> Cada uno de los comandos aquí mostrados deberán ser ejecutados en el Nodo Control con el usuario dedicado para las tareas Ansible.

> Nota: El playbook contiene una sección que pausa la ejecución del mismo, esto es con el motivo de permitir el tiempo suficiente para permitir que uno de los Pods pueda levantar.

Haciendo uso del plabook ubicado en este repositorio realizamos la restauración del quorum.

```
ansible-playbook -i <inventario> /opt/okd-devtech/playbooks/5.RestoringQuorum.yml
```