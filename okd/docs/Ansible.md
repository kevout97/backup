# Ansible

Configuración del servicio Ansible para despliegue y configuración de OKD

## Prerequisitos

* Permisos de superusuario
* Servidor dedicado
* Debe existri el grupo de linux **operaciones**

## Desarrollo

### Instalación de Ansible

Para el despliegue de OKD se requiere una versión 2.6 o mayor de Ansible, la via más rápida para su instalación en los SO Rhel7 es a traves del repositorio EPEL.

```bash
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y
```

Instalación de Ansible

```bash
yum install ansible -y
```

### Usuario Ansible

A continuación generamos un usuario dedicado, con el cual se llevarán a cabo cada uno de los despliegues.

```bash
sudo useradd -g operaciones -m ansible
```

A dicho usuario le otorgamos permisos de superusuario en el archivo */etc/sudoers*.

```bash
sudo echo "ansible ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
```

Logueados como el usuario **ansible** ```sudo su ansible``` generamos las llaves rsa para la conexión con los demas servidores.

`Generamos el directorio donde se almacenarán las llaves rsa`
```bash
mkdir -p ~/.ssh
```

`Solo damos enter en cada una de las opciones`
```bash
ssh-keygen -b 4096 -t rsa
```

Si se mantuvieron las opciones por defecto el comando generará dos archivos ubicados en **/home/asible/.ssh/**, nombrados id_rsa.pub, id_rsa.

Añadimos la llave privada al agente ssh de dicho usuario para permitir la conexión con los otros servidores.

```bash
eval $(ssh-agent -s)
ssh-add /home/asible/.ssh/id_rsa
```

### Alta del usuario Ansible

Una vez que el usuario Ansible ha sido configurado en el servidor que llevará a cabo los despliegues, damos de alta en el resto de los servidores del cluster a dicho usuario.

```bash
useradd -m -g operaciones ansible
mkdir -p /home/ansible/.ssh/
touch /home/ansible/.ssh/authorized_keys
chmod 700 /home/ansible/.ssh/
chmod 600 /home/ansible/.ssh/authorized_keys
echo 'PUBLIC_KEY' > /home/ansible/.ssh/authorized_keys
chown ansible /home/ansible/ -R
```

Donde:
* **PUBLIC_KEY** es el contenido del archivo /home/asible/.ssh/id_rsa.pub

Finalmente verificamos que la conexión con todos los servidores se pueda llevar a cabo.

**NOTA**: Se asume que en el inventario se tiene una sección **[all]** en el que se encuentra la Ip o hostname de todos los servidores que conforman el cluster.

```bash
ansible -m ping -i [inventory] all
```