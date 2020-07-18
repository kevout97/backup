# Load Balancer

> Los siguientes comandos deberán ser ejecutados en el servidor dedicado como Nodo de Control (El que tiene instalado Ansible).

## Desarrollo

### Configuración de archivo haproxy.cfg

> Las modificaciones deberán realizarse en ambos backend del archivo, **atomic-openshift-api** y **router-openshift-ssl-2**

Antes de llevar a cabo la ejecución del playbook es importante configurar el archivo */opt/okd-devtech/playbooks/haproxy.cfg*.

```conf
    server      master0 10.10.27.4:8443 check
```

Se deberá colocar la Ip de los servidores Master, dicha Ip debe ser conocida por el servidor Load Balancer.

En caso de tener mas de un Master, basta con agregar mas líneas similares, es importante cuidar el id asociado a ese servidor master. En el ejemplo anterior dicho id es **master0**.

A contnuación se muestra un ejemplo de como luciria esa sección con mas nodos master.

```bash
    server      master0 10.10.27.4:8443 check
    server      master1 10.10.27.5:8443 check
```

### Ejecución del Playbook

> Los siguientes comandos deberán ser ejecutados como el usuario Ansible.

```bash
sudo su ansible
```

Realizamos el acondicionamiento del servidor dedicado como Load Balancer.

*Nos ubicamos en el directorio donde se encuentra el playbook*
```bash
cd /opt/okd-devtech/playbooks/
```

*Ejecución del playbook. Suponemos que el inventario es **/opt/okd-devtech/playbooks/0.inventory***
```bash
ansible-playbook -i /opt/okd-devtech/playbooks/0.inventory /opt/okd-devtech/playbooks/3.preparing-host-lb.yml
```