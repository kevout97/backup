# Configuración Inventario

> Antes de llevar a cabo el despliegue de OKD es preciso ajustar los valores del inventario que se muestran a continuación, a la configuración propia.

En cuanto a los grupos del inventario:
* **[OSEv3:children]**: Se indican los grupos utilizados por OKD.
* **[OSEv3:vars]**: Se definen las variables con las que se configurará OKD
* **[all]**: Todos los nodos
* **[okd]**: Solo los nodos de OKD, se excluyen los que conforman a los nodos de Ceph, este grupo es utilizado por los playbooks creados para la preparación de los hosts.
* **[etcd]**: Se indican los nodos que serán etcd.
* **[masters]**: Se indican los nodos que serán master.
* **[nodes]**: Solo los nodos de OKD, se excluyen los que conforman a los nodos de Ceph, este grupo es utilizado por los playbooks con los que se levanta OKD.
* **[app]**: Se indican los nodos app de OKD, este grupo es utilizado por los playbooks con los que se levanta OKD.
* **[lb]**: Se indican los nodos app de OKD, este grupo es utilizado por los playbooks con los que se levanta OKD.
* **[ceph]**: Se indican los nodos que conformarán al cluster de Ceph, este grupo es utilizado por los playbooks creados para la preparación de los hosts.
  
Etiquetas utilizadas en el grupo **[nodes]**
* **\<FQDN del servidor\> openshift_node_group_name='node-config-master'**: Permite definir que nodos son los de master.
* **\<FQDN del servidor\> openshift_node_group_name='node-config-infra'**: Permite definir que nodos se son los de infra.
* **\<FQDN del servidor\> openshift_node_group_name='node-config-compute'**: Permite definir que nodos se son los de app.

*En las siguientes variables apuntar al dominio asociado a la consola de Openshift*

> El dominio de la consola debe apuntar a la Ip del LoadBalancer.

```conf
openshift_master_cluster_hostname
openshift_master_cluster_public_hostname
openshift_console_hostname
```

*La siguiente variable configura el primer usuario de Openshift, utilizando htpasswd*
```conf
openshift_master_htpasswd_users
```

> Las siguientes configuraciones aplican cuando se tiene considerado el aprovisionamiento dinámico de los volúmenes.

*Se habilita el aprovisionamiento dinámico de los volúmenes*
> En caso de hacer un despliegue sin almacenamiento dinámico colocar esta sección como **false** y omitir las configuraciones restantes. Importante comentar las variables en el inventario
```conf
openshift_master_dynamic_provisioning_enabled=true
```

*Se habilita el aprovisionamiento dinámico de los volúmenes de las metricas.*
```conf
openshift_metrics_cassandra_storage_type=dynamic
```

*Nombre del Storga Class configurado para el aprovisionamiento dinámico de las metricas*
> Dicho valor debe coincidir con el valor configurado en la creación del Storage Class [StorageClass](PostInstall.md)
```conf
openshift_metrics_cassandra_pvc_storage_class_name="dynamic"
```

*Nombre del Storga Class configurado para el aprovisionamiento dinámico del logging*
> Dicho valor debe coincidir con el valor configurado en la creación del Storage Class [StorageClass](PostInstall.md)
```conf
openshift_logging_es_pvc_storage_class_name="dynamic"
```

*Tamaño del volumen utilizado para las metricas*
```conf
openshift_metrics_storage_volume_size
```

*Tamaño del pvc para el logging del cluster*
```conf
openshift_logging_es_pvc_size=100Gi
```

*Tamaño del pvc para las metricas del cluster*
```conf
openshift_metrics_storage_volume_size=100Gi
```