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
htpasswd -nb <user_name> <password> >> /etc/origin/master/htpasswd
```

> Los siguientes comandos deberán ser ejecutados desde un Nodo Master, con privilegios de super usuarios.

*Logueo en OKD como administrador*
```bash
oc login -u system:admin
```

*Otorgamos los permisos de administrador de cluster al usuario creado anteriormente*
```bash
oc create clusterrolebinding <username> --clusterrole=cluster-admin --user=<username>
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

## Issues 

**Problema**

```bash
standard_init_linux.go:178: exec user process caused "no such file or directory"
```

El problema anterior representa un bug de la imagen con la cual se despliega el pod de monitoreo de Grafana.

```bash
docker.io/grafana/grafana:5.2.1
```

**Solución**

La solución al bug anterior es subir la versión de la imagen de la **docker.io/grafana/grafana:5.2.1** a la **docker.io/grafana/grafana:5.2.2**.

*Ubicados en el servidor donde se hizo del despliegue del Pod de Grafana del proyecto openshift-monitoring, descargamos la nueva imagen*
```bash
docker pull docker.io/grafana/grafana:5.2.2
```

*Eliminamos la imagen anterior*
```bash
docker rmi -f docker.io/grafana/grafana:5.2.1
```

*Reetiquetamos la imagen más reciente para que el Deployment realice el despliegue con dicha imagen*
```bash
docker tag docker.io/grafana/grafana:5.2.2 docker.io/grafana/grafana:5.2.1
```

En la consola web eliminamos el Pod de Grafana para que de manera automática se realice el despliegue del nuevo contenedor con la nueva imagen.


**Problema**

```bash
cat: /opt/app-root/src/init_failures: No such file or directory
```

Cuando se inicia el pod, se ejecuta el script init.sh. Este script crea un archivo vacío "init_complete" una vez finalizado con éxito o, en caso de error, crea el archivo "init_faiures" con el motivo del error como contenido.

La sonda de preparación de elasticsearch pod está comprobando si la fase de inicio ha sido exitosa (verificando la existencia del archivo init_complete) o informa el error (contenido de fallo_inicial). 

**Solución**

Dentro de un nodo Master ejecutar el siguiente comando.

*Nos logueamos en OKD*
```bash
oc login -u system:admin
```

*Nos ubicamos en el proyecto donde se encuentra el Pod de Elastic*
```bash
oc project openshift-logging
```

*Creamos un archivo vacío dentro del contenedor*
> El Pod de Elasticsearch debe estar en ejecución

```bash
for p in $(oc get pods -l component=es -o jsonpath={.items[*].metadata.name}); do   oc exec -c elasticsearch $p -- touch /opt/app-root/src/init_failures;  done
```