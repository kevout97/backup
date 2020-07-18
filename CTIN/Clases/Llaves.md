El comando shh tiene la siguiente estructura, pero las opciones no son necesarios

ssh-keygen [-q] [-b bits] [-t type dsa | ecdsa | ed25519 | rsa ] [-N new_passphrase] [-C comment] [-f output_keyfile]

https://linux.die.net/man/1/ssh-keygen

Cada usuario tiene diferentes llaves, por lo que se le puede asignar la llave al usuario personal o al usuario root.

Nosotros generamos las llaves de esta forma, indicando el algoritmo, la longitud y el comenatio o nombre de la llave. Se abrira un proceso interactvo para indicar el directorio o filename de la llave, el predeterminado para root  es /root/.ssh/id_rsa y para el usuario /home/username/.ssh/id_rsa la contraseña que deseamos

ssh-keygen -t rsa -b 4098 -C "usuario.apellido"

Tambien podemos utilizar las banderas de contraseña y del directorio

ssh-keygen -t rsa -b 4096 -C usuario.apellido -P n0m3l0 -f /home/$USER/.ssh/id_rsa

La llave que generen debe ser agregada al servidor SSH, esto se hace con los siguientes comandos

useradd -m -g operaciones usuario.apellido
mkdir -p /home/usuario.apellido/.ssh/
touch /home/usuario.apellido/.ssh/authorized_keys
chmod 700 /home/usuario.apellido/.ssh/
chmod 600 /home/usuario.apellido/.ssh/authorized_keys
echo 'ssh-rsa contenido de la llave publica que esta en el directorio donde el cliente creo su llave /home/USER/id_rsa.pub ' > /home/usuario.apellido/.ssh/authorized_keys
chown usuario.apellido:operaciones /home/usuario.apellido/ -R
echo 'usuario.apellido  ALL=(ALL)      NOPASSWD: ALL' >> /etc/sudoers

Para acceder al servidor de ssh de jablab se necesita haber generado la llave y poner estos comandos

eval $(ssh-agent -s)

ssh-add /root/.ssh/

ssh -o ServerAliveInterval=60 usuario.apellidos@201.161.97.8


https://www.ssh.com/ssh/key/
https://linux.die.net/man/1/ssh-keygen
