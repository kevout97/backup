# Arquitectura de OKD

## Aprovisionamiento de Infraestructura

Arquitectura propuesta para cluster de OKD básico.

|Host (VM)      |   Nodo        |   vCPUs   |  RAM \[GB] |  HDD (Base)  |  HDD (Adicional)  |
|---------------|---------------|-----------|------------|--------------|-------------------|
|OKDAMXMAST1-1  |  Master/etcd  |     8     |     16     |      50      |        500        |
|OKDAMXMAST2-2  |  Master/etcd  |     8     |     16     |      50      |        500        |
|OKDAMXMAST3-2  |  Master/etcd  |     8     |     16     |      50      |        500        |
|OKDAMXAPP1-1   |   App/Infra   |     8     |     16     |      50      |        500        |
|OKDAMXAPP2-1   |   App/Infra   |     8     |     16     |      50      |        500        |
|OKDAMXLB1-1    | Load Balancer |     8     |     16     |      50      |        500        |
|OKDAMXCEPH1-2  |     Ceph      |     8     |     16     |      50      |       1024        |
|OKDAMXCEPH2-1  |     Ceph      |     8     |     16     |      50      |       1024        |
|OKDAMXCEPH3-1  |     Ceph      |     8     |     16     |      50      |       1024        |
|OKDAMXCEPH4-1  |     Ceph      |     8     |     16     |      50      |       1024        |
|               |               |           |            |              |                   |

## Basics for VMs

Para cada VM se realizarán los pasos básicos necesarios.

+ Hardening inicial.
+ Configuración persistente de default gateway.
+ Pruebas de conectividad externas.

### Hardening RHEL 7

El script para realizar el hardening se encuentra en [rhel7_hardening-2020.sh](../scripts/rhel7_hardening-2020.sh)