# Despliegue OKD

> **Todo el despliegue de OKD debe hacerse desde el nodo de control (El nodo que tiene ansible)**

## Prerrequisitos para el despliegue

* Haber clonado el repositorio [OKD AMX](https://infracode.amxdigital.net/desarrollo-tecnologico/okd/tree/master) en el home del usuario ansible.
* Clonar el repositorio oficial de OKD en el home del usuario ansible ([OKD 3.11](https://github.com/openshift/openshift-ansible)).
* DNS correctamente configurado con el mismo hostname en cada vm cumpliendo con un FQDN.
* Paquetes necesarios en nodo de control.
* Usuario ansible en todos los nodos del cluster.
* Edición del inventario según necesidades del cluster. ([Inventario](../playbooks/0.inventory))
* Setup completo de volúmenes para el cluster.


Clonar repositorios.

```sh
git clone -b release-3.11 https://github.com/openshift/openshift-ansible.git /opt/openshift-ansible
```

Asignamos permisos para que el usario de Ansbile pueda navegar sin problemas dentro del directorio

*E.g. Suponemos que el usuario de Ansible se llama **ansible** y se cuenta con el grupo de linux **operaciones***
```bash
sudo chown ansible:operaciones -R /opt/openshift-ansible
```

Instalar los paquetes requeridos en el nodo de control.

```sh
yum install -y httpd-tools java-1.8.0-openjdk-headless
```

Probar la conexión con ansible desde el nodo de control.

```sh
ansible -m ping -b -i /opt/okd-devtech/playbooks/0.inventory all
```

Agregar repositorio de Openshift origin

```sh
echo 'W2NlbnRvcy1vcGVuc2hpZnQtb3JpZ2luMzExXQpuYW1lPUNlbnRPUyBPcGVuU2hpZnQgT3JpZ2luCmJhc2V1cmw9aHR0cDovL21pcnJvci5jZW50b3Mub3JnL2NlbnRvcy83L3BhYXMveDg2XzY0L29wZW5zaGlmdC1vcmlnaW4zMTEvCmVuYWJsZWQ9MQpncGdjaGVjaz0wCgpbY2VudG9zLW9wZW5zaGlmdC1vcmlnaW4zMTEtdGVzdGluZ10KbmFtZT1DZW50T1MgT3BlblNoaWZ0IE9yaWdpbiBUZXN0aW5nCmJhc2V1cmw9aHR0cDovL2J1aWxkbG9ncy5jZW50b3Mub3JnL2NlbnRvcy83L3BhYXMveDg2XzY0L29wZW5zaGlmdC1vcmlnaW4zMTEvCmVuYWJsZWQ9MApncGdjaGVjaz0wCgoKW2NlbnRvcy1vcGVuc2hpZnQtb3JpZ2luMzExLWRlYnVnaW5mb10KbmFtZT1DZW50T1MgT3BlblNoaWZ0IE9yaWdpbiBEZWJ1Z0luZm8KYmFzZXVybD1odHRwOi8vZGVidWdpbmZvLmNlbnRvcy5vcmcvY2VudG9zLzcvcGFhcy94ODZfNjQvCmVuYWJsZWQ9MApncGdjaGVjaz0wCgpbY2VudG9zLW9wZW5zaGlmdC1vcmlnaW4zMTEtc291cmNlXQpuYW1lPUNlbnRPUyBPcGVuU2hpZnQgT3JpZ2luIFNvdXJjZQpiYXNldXJsPWh0dHA6Ly92YXVsdC5jZW50b3Mub3JnL2NlbnRvcy83L3BhYXMvU291cmNlL29wZW5zaGlmdC1vcmlnaW4zMTEvCmVuYWJsZWQ9MApncGdjaGVjaz0wCgo=' | base64 -d > CentOS-OpenShift-Origin311.repo
ansible -m copy -a "src=CentOS-OpenShift-Origin311.repo  dest=/etc/yum.repos.d/CentOS-OpenShift-Origin311.repo owner=root group=root mode='644'" -b -i /opt/okd-devtech/playbooks/0.inventory all
ansible -a "bash -c 'yum clean all'" -b -i /opt/okd-devtech/playbooks/0.inventory all
rm -f CentOS-OpenShift-Origin311.repo
```

## Ejecución de playbooks

### Preparación de hosts previa a instalación OKD

```sh
ansible-playbook -i /opt/okd-devtech/playbooks/0.inventory -b /opt/okd-devtech/playbooks/1.preparing-hosts.yml -v
```

### Playbooks de instalación OKD

> Recomendamos correr uno por uno los playbooks e ir atendiendo issues que salgan.

```sh
cd /opt/openshift-ansible/playbooks

ansible-playbook -i /opt/okd-devtech/playbooks/0.inventory -vvvv openshift-checks/pre-install.yml
ansible-playbook -i /opt/okd-devtech/playbooks/0.inventory -vvvv openshift-node/bootstrap.yml
ansible-playbook -i /opt/okd-devtech/playbooks/0.inventory -vvvv openshift-etcd/config.yml
ansible-playbook -i /opt/okd-devtech/playbooks/0.inventory -vvvv openshift-loadbalancer/config.yml
ansible-playbook -i /opt/okd-devtech/playbooks/0.inventory -vvvv openshift-master/config.yml
ansible-playbook -i /opt/okd-devtech/playbooks/0.inventory -vvvv openshift-master/additional_config.yml
ansible-playbook -i /opt/okd-devtech/playbooks/0.inventory -vvvv openshift-node/join.yml
ansible-playbook -i /opt/okd-devtech/playbooks/0.inventory -vvvv openshift-hosted/config.yml
ansible-playbook -i /opt/okd-devtech/playbooks/0.inventory -vvvv openshift-monitoring/config.yml
ansible-playbook -i /opt/okd-devtech/playbooks/0.inventory -vvvv openshift-web-console/config.yml
ansible-playbook -i /opt/okd-devtech/playbooks/0.inventory -vvvv openshift-console/config.yml
ansible-playbook -i /opt/okd-devtech/playbooks/0.inventory -vvvv openshift-metrics/config.yml
ansible-playbook -i /opt/okd-devtech/playbooks/0.inventory -vvvv metrics-server/config.yml
ansible-playbook -i /opt/okd-devtech/playbooks/0.inventory -vvvv openshift-logging/config.yml
ansible-playbook -i /opt/okd-devtech/playbooks/0.inventory -vvvv openshift-monitor-availability/config.yml
ansible-playbook -i /opt/okd-devtech/playbooks/0.inventory -vvvv openshift-descheduler/config.yml
ansible-playbook -i /opt/okd-devtech/playbooks/0.inventory -vvvv openshift-autoheal/config.yml
ansible-playbook -i /opt/okd-devtech/playbooks/0.inventory -vvvv olm/config.yml
```
