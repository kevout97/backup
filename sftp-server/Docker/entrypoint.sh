#!/bin/bash
# Created by Mauricio Mp & Kevs | If you want something to go well, do it right
function verify_ssh_keys(){
    #Aqui creamos el usuario con el que se van a poder conectar al sftp
    if [ "$(ls -A /home/$SFTP_USER/.ssh/)" ]; then
        echo "[AMX] The directory /home/$SFTP_USER/.ssh/ isn't empty"
        echo "[AMX] Using existing keys"
        chmod 700 /home/$SFTP_USER/.ssh/
        chmod 600 /home/$SFTP_USER/.ssh/authorized_keys
        chown $SFTP_USER:operaciones /home/$SFTP_USER/ -R
    else
        echo "[AMX] The directory /home/$SFTP_USER/.ssh/ is empty"
        echo "[AMX] Use SFTP_USER_KEY variable"
        if [ ! -z "${SFTP_USER_KEY}" ]; then
            touch /home/$SFTP_USER/.ssh/authorized_keys
            chmod 700 /home/$SFTP_USER/.ssh/
            chmod 600 /home/$SFTP_USER/.ssh/authorized_keys
            echo $SFTP_USER_KEY > /home/$SFTP_USER/.ssh/authorized_keys
            chown $SFTP_USER:operaciones /home/$SFTP_USER/ -R
        else
            echo "[AMX] Key not found"
            exit 2
        fi
    fi
}

function check_variables(){
    if [ ! -z "${SFTP_USER}" ]; then
        echo "[AMX] Create \"$SFTP_USER\" user"
        mkdir -p /home/$SFTP_USER/.ssh/
        if [ ! -z "${SFTP_USER_KEY}" ]; then
            useradd -m -g operaciones $SFTP_USER
            sed -e 's/PasswordAuthentication.*/PasswordAuthentication no/' -i /etc/ssh/sshd_config
            verify_ssh_keys
        # En esta parte es donde pretendo estableces la cuestion de la contraseña
        elif [ ! -z "${SFTP_USER_PASSWORD}" ]; then
            useradd -m --password $SFTP_USER_PASSWORD -g operaciones $SFTP_USER
            sed -e 's/PasswordAuthentication.*/PasswordAuthentication yes/' -i /etc/ssh/sshd_config
        else
            echo "[AMX] Key or Password not found"
            exit 3
        fi
    else
        echo "[AMX] User to sftp service not found"
        exit 2
    fi

    #En esta parte es donde especificamos el directorio donde se podran escribir y crear las cosas
    # si la bariable $SFTP_DIRECTORY no esta declarada por defecto vamos a usar /var/share
    # el directorio yo lo escogi no tiene nada de especial
    if [ "${SFTP_DIRECTORY}" ]; then
        echo "[AMX] Specifying $SFTP_DIRECTORY as storage directory"
        mkdir -p $SFTP_DIRECTORY
        chown root:root $SFTP_DIRECTORY
        chmod -R 755 $SFTP_DIRECTORY
        echo " 	ChrootDirectory $SFTP_DIRECTORY" >> /etc/ssh/sshd_config
        mkdir -p $SFTP_DIRECTORY/$SFTP_USER
        chmod 700 -R $SFTP_DIRECTORY/$SFTP_USER
        chown $SFTP_USER $SFTP_DIRECTORY/$SFTP_USER
    else
        echo "[AMX] Specifying /var/share as storage directory"
        mkdir -p /var/share
        chown root:root /var/share
        chmod -R 755 /var/share
        echo " 	ChrootDirectory /var/share" >> /etc/ssh/sshd_config
        mkdir -p /var/share/$SFTP_USER
        chmod 700 -R /var/share/$SFTP_USER
        chown $SFTP_USER /var/share/$SFTP_USER
    fi
}

if [ "$(ls -A /etc/ssh/)" ]; then
    echo "[AMX] Configuration sshd service"
    #Configuracion de ssh (Eso esta bien)
    ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa -b 4096  < <(echo yes) 1>/dev/null
    ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa -b 521  < <(echo yes) 1>/dev/null
    ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N '' -t ecdsa -b 521  < <(echo yes) 1>/dev/null
    sed -e 's/^#UseDNS.*/UseDNS no/' -i /etc/ssh/sshd_config
    sed -e 's/^Subsystem	sftp	\/usr\/libexec\/openssh\/sftp-server/#Subsystem	sftp	\/usr\/libexec\/openssh\/sftp-server/' -i /etc/ssh/sshd_config
    sed -e 's/^PasswordAuthentication.*/PasswordAuthentication no/' -i /etc/ssh/sshd_config
    #Configuracion de sftp (Por lo que veo esto tambien esta bien)
    echo -e "Subsystem	sftp	internal-sftp" >> /etc/ssh/sshd_config
    echo -e " 	Match Group operaciones" >> /etc/ssh/sshd_config
    echo -e " 	X11Forwarding no" >> /etc/ssh/sshd_config
    echo -e " 	AllowTcpForwarding no" >> /etc/ssh/sshd_config
    echo -e " 	ForceCommand internal-sftp" >> /etc/ssh/sshd_config
    check_variables
fi

echo "[AMX] Started Sftp"
while true; do
    SSHD_PID=$(pgrep sshd)
    if [ -z "${SSHD_PID}" ]; then
        #Prendemos ssh (Si usas -d se prende en modo verbose y arroja un chingo de madres)
        exec /usr/sbin/sshd -D
    fi
done