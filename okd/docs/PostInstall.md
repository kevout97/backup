# Pasos Post Instalación

## Creación de Router

> Los siguientes comandos deberán ser ejecutados desde un Nodo Master, con privilegios de super usuario.

*Logueo en OKD como administrador*
```bash
oc login -u system:admin
```

*Nos situamos en el proyecto openshift-infra*
```bash
oc project openshift-infra
```

*Agregamos el contexto para el manejo de red a la cuenta de servicio **router***
```bash
oc adm policy add-scc-to-user hostnetwork -z router
```

*Preparamos el dc para despliegue del router*
```bash
oc adm router openshift-router --replicas=0 --service-account=router
```

*Configuramos al router para hacer uso del wildcard asociado a OKD*
```bash
oc set env dc/openshift-router ROUTER_ALLOW_WILDCARD_ROUTES=true
```

*Realizamos el despliegue del Router*
```bash
oc scale dc/openshift-router --replicas=1
```

## Creación de usuarios

> Los siguientes comandos deberán ser ejecutados en cada Nodo Master, con privilegios de super usuarios.

*Creación de usuario y contraseña*
```bash
htpasswd -c -B -b /etc/origin/master/htpasswd <user_name> <password>
```

> Los siguientes comandos deberán ser ejecutados desde un Nodo Master, con privilegios de super usuarios.

*Logueo en OKD como administrador*
```bash
oc login -u system:admin
```

*Otorgamos los permisos de administrador de cluster al usuario creado anteriormente, en los siguentes proyectos*
```bash
oc adm policy add-role-to-user cluster-admin <user_name> -n default
oc adm policy add-role-to-user cluster-admin <user_name> -n kube-public
oc adm policy add-role-to-user cluster-admin <user_name> -n kube-service-catalog
oc adm policy add-role-to-user cluster-admin <user_name> -n kube-system
oc adm policy add-role-to-user cluster-admin <user_name> -n management-infra
oc adm policy add-role-to-user cluster-admin <user_name> -n openshift
oc adm policy add-role-to-user cluster-admin <user_name> -n openshift-console
oc adm policy add-role-to-user cluster-admin <user_name> -n openshift-infra
oc adm policy add-role-to-user cluster-admin <user_name> -n openshift-logging
oc adm policy add-role-to-user cluster-admin <user_name> -n openshift-metrics-server
oc adm policy add-role-to-user cluster-admin <user_name> -n openshift-monitoring
oc adm policy add-role-to-user cluster-admin <user_name> -n openshift-node
oc adm policy add-role-to-user cluster-admin <user_name> -n openshift-node-problem-detector
oc adm policy add-role-to-user cluster-admin <user_name> -n openshift-operator-lifecycle-manager
oc adm policy add-role-to-user cluster-admin <user_name> -n openshift-sdn
oc adm policy add-role-to-user cluster-admin <user_name> -n openshift-web-console
oc adm policy add-role-to-user cluster-admin <user_name> -n operator-lifecycle-manager
```

## Integración cluster de Ceph

> La configuración aqui mostrada solo aplica cuando se tiene almacenamiento dinámico proporcionado por Ceph

> El siguiente comando deberá ser ejecutado en un Nodo Mon de Ceph con privilegios de superusuario

*Obtenemos la key en base64 para autenticación con Ceph*
```bash
ceph auth get-key client.admin | base64
```

*Creamos el pool utilizado por OKD*
```bash
ceph osd pool create kube 128
```

> Los siguientes comandos deberán ser ejecutados desde un Nodo Master, con privilegios de super usuarios.

*Logueo en OKD como administrador*
```bash
oc login -u system:admin
```

*Nos ubicamos en el proyecto kube-system*
```bash
oc project kube-system
```

*Creación del yaml para el objeto Secret de la Key de Ceph*
```bash
cat<<-EOF > ceph.secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: ceph-secret # Nombre del secret con la key de Ceph
data:
  key: QVFBOFF2SlZheUJQRVJBQWgvS2cwT1laQUhPQno3akZwekxxdGc9PQ== # Key obtenida en pasos anteriores
type: kubernetes.io/rbd 
EOF
```

*Creación del yaml para el objeto StorageClass de Ceph*
```bash
cat<<-EOF > ceph.storage.class.yaml
apiVersion: storage.k8s.io/v1beta1
kind: StorageClass
metadata:
  name: dynamic # Nombre del Storage Class
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: kubernetes.io/rbd
parameters:
  monitors: 192.168.1.11:6789,192.168.1.12:6789,192.168.1.13:6789 # Ip de los Nodos Mon de Ceph
  adminId: admin
  adminSecretName: ceph-secret # Nombre del secret con la key de Ceph
  adminSecretNamespace: kube-system 
  pool: kube  
  userId: admin  
  userSecretName: ceph-secret # Nombre del secret con la key de Ceph
EOF
```

*Creacion de objetos Secret y StorageClass*
```bash
oc create -f ceph.secret.yaml
oc create -f ceph.storage.class.yaml
```

A continuación modificamos el Template con el que se crean los proyectos en OKD. Con dichas modificaciones integraremos la creación del objeto Secret con la key para la autenticación con Ceph

> Todos los comandos deberán ser ejecutados en un Nodo Master

*Logueo en OKD como administrador*
```bash
oc login -u system:admin
```

*Obtenemos el template actual con el que se crean los proyectos en OKD*
```bash
oc adm create-bootstrap-project-template -o yaml > template.yaml
```

*Integramos la definición del objeto Secret con la key de Ceph*
> Modificamos el archivo template.yaml
```yaml
apiVersion: v1
kind: Template
metadata:
  creationTimestamp: null
  name: project-request
objects:
- apiVersion: v1
  kind: Project
  ....

- apiVersion: v1
  kind: Secret
  metadata:
    name: ceph-secret # Nombre del secret con la key de Ceph
  data:
    key: QVFCbEV4OVpmaGJtQ0JBQW55d2Z0NHZtcS96cE42SW1JVUQvekE9PQ== # Key obtenida en pasos anteriores
  type:
    kubernetes.io/rbd
    ....
```

*Nos ubicamos en el proyecto openshift*
```bash
oc project openshift
```

*Creamos el Template de los proyectos*
```bash
oc create -f template.yaml
```

> Las siguientes modificaciones deberán realizarse en cada uno de los Nodos Master

*Indicamos el Template con el que se crearán los proyectos a partir de este instante*

*Modificamos el archivo **/etc/origin/master/master-config.yaml***
```yaml
...
projectConfig:
  projectRequestTemplate: "openshift/project-request"
...
```

*Recargamos el Api de Openshift para hacer efectivos los cambios*

> El siguiente comando deberá ser ejecutado desde el nodo Ansible. Se da por hecho que el inventario contiene una sección [masters]

```bash
ansible -a "bash -c '/usr/local/bin/master-restart api'" masters -i <inventario>
ansible -a "bash -c '/usr/local/bin/master-restart controllers'" masters -i <inventario>
```