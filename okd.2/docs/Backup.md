# Creación de Backup OKD

## Prerequisitos

* Cluster de OKD
* Sección [okd] en el [inventario](../playbooks/0.inventory).
  
## Desarrollo

### Backup Nodos

Por defecto el backup de OKD se realizará en el directorio **/opt/backup-okd** en caso de querer modificar esta ruta deberá modificarse en la siguiente sección del inventario.

```conf
....
[okd:vars]
okd_backup_directory=/opt/backup-okd
....
```

Con la variable **okd_backup_directory** señalamos el directorio donde deseamos realizar el backup.

Realizamos el backup con el uso del siguiente comando.

> Se toma por hecho que este repositorio se encuentra clonado en /opt/okd-devtech

```bash
ansible-playbook -i <inventario> /opt/okd-devtech/playbooks/4.backup.yml
```

> Importante: Si el servidor dedicado como Load Balancer esta en la sección [okd] del inventario es normal observar errores del tipo "No such file or directory", ya que dicho servidor no contiene  configuración propia de OKD, mas allá de la que se encuentra en la configuración de Haproxy.

## Backup data ETCD

Realizamos el backup con el uso del siguiente comando.

> Se toma por hecho que este repositorio se encuentra clonado en /opt/okd-devtech

```bash
ansible-playbook -i <inventario> /opt/okd-devtech/playbooks/6.etcd-data-backup.yml
```

Se guardará el snapshot en */var/lib/etcd/snapshot.db*, al ser un volúmen montado no es recomendable cambiar la ruta donde se almacenará el snapshot.