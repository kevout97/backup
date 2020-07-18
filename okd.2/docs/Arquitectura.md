# Arquitectura de OKD

## Aprovisionamiento de Infraestructura

> A continuación se muestran los requerimientos mínimos para el despliegue de OKD.

Arquitectura propuesta para cluster de OKD básico.

|Host (VM)      |   Nodo        |   vCPUs   |  RAM \[GB] |  HDD (Base)  |  HDD (Adicional)  |
|---------------|---------------|-----------|------------|--------------|-------------------|
|OKDMAST1-1     |  Master/etcd  |     4     |     8      |      50      |        100        |
|OKDAPP1-1      |   App         |     4     |     8      |      50      |        200        |
|OKDINFRA1-1    |   Infra       |     4     |     8      |      50      |        200        |
|OKDLB1-1       | Load Balancer |     2     |     4      |      50      |        100        |

## Basics for VMs

Para cada VM se realizarán los pasos básicos necesarios.

+ Hardening inicial.
+ Configuración persistente de default gateway.
+ Pruebas de conectividad externas.
+ Kernel

### Hardening RHEL 7

Para realizar el hardening se utiliza el playbook [0.5.hardening-hosts.yml](../playbooks/0.5.hardening-hosts.yml)
> El script para realizar el hardening se encuentra en [rhel7_hardening-2020.sh](../scripts/rhel7_hardening-2020.sh)

Desde el usuario ansible

```sh
ansible-playbook -i ~/okd/playbooks/0.inventory-vcloud -v ~/okd/playbooks/0.5.hardening-hosts.yml
```

**Nota importante:** Si el despliegue se hace sobre la nueva vcloud usando hosts con la imagen template de rhel7:

+ Red Hat Enterprise Linux Server release 7.6 (Maipo) Red Hat 7.6 MySQL - Hasta 4 vCPU

Correr estos comandos ansible

```sh
ansible -a "bash -c 'rm -f /etc/yum.repos.d/mysql*'" -i ~/okd/playbooks/0.inventory-vcloud all
ansible -a "bash -c 'yum remove -y mysql kmod-kvdo'" -i ~/okd/playbooks/0.inventory-vcloud all
ansible -a "bash -c 'echo \"nobody:x:99:\" >> /etc/group'" -i ~/okd/playbooks/0.inventory-vcloud all
ansible -a "bash -c 'echo \"nobody:x:99:99:Nobody:/:/sbin/nologin\" >> /etc/passwd'" -i ~/okd/playbooks/0.inventory-vcloud all 
```

### Kernel necesario

Para la instalación de OKD es necesario tener la última versión del kernel, en este caso *Linux 3.10.0-1127.el7.x86_64*

Se puede verificar con el comando:

```sh
uname -rs
```