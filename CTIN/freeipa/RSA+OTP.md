# RSA Keys + OTP Authentication

Añadimos el Repositorio EPEL.
```bash
sudo wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo rpm -Uvh epel-release-latest-7.noarch.rpm
```
Instalamos los paquetes necesarios para la generación del OTP.
```bash
sudo yum install liboath gen-oath-safe pam_oath
```
## Generación de OTP
```bash
gen-oath-safe user totp
```
Reemplazamos 'user' por el usuario la cual se le está generando su OTP.

La opción 'totp' indica que será un *time-based one-time password*, de igual forma se puede poner 'hotp' para *HMAC-based one-time password*.

Un código QR con información extra aparecerá en la terminal, escanearlo con una aplicación de autenticación OTP (FreeOTP por ejemplo)

![QR code](https://gitlab.ctin-uat.amxdigital.net/el-laure5/freeipa/raw/master/Images/qrotp.png)

Aparecerá una línea debajo del código QR con un *Hex code* en donde aparece el nombre de usuario al cual le preparamos el OTP, algo como esto:
```bash
HOTP/T30 user - 77dc6abb5d0452eb87de5b8a4129c689bbea18af
```
Copia esa línea y añádela a un nuevo archivo que crearemos para posteriormente utilizarlo.
```bash
echo 'HOTP/T30 user - 77dc6abb5d0452eb87de5b8a4129c689bbea18af' | sudo tee -a /etc/liboath/users.oath
```
**Este proceso debe ser repetido para cada usuario que desea tener una autenticación a dos pasos por OTP**

Añade la siguiente linea al archivo */etc/pam.d/sshd*
```bash
auth    required    pam_oath.so usersfile=/etc/liboath/users.oath window=10 digits=6
```
Esta línea especifica cuatro criterios: el módulo PAM OATH como un método de autenticación adicional, la ruta del archivo de usuarios, una ventana que especifica qué frases de contraseña se aceptarán (para tener en cuenta los posibles problemas de sincronización de tiempo) y un código de verificación de longitud de seis dígitos

Edite */etc/ssh/sshd_config* para incluir las siguientes líneas, sustituyendo al usuario de ejemplo con cualquier usuario del sistema para el que desee habilitar la autenticación de dos factores.
```bash
Match User usuario
    AuthenticationMethods publickey,keyboard-interactive
```
>**Nota** Si desea aplicar la autenticación de dos factores globalmente, puede usar la directiva AuthenticationMethods por sí misma, fuera de un bloque de coincidencia de usuarios. Sin embargo, esto no debe hacerse hasta que se hayan proporcionado credenciales de dos factores a todos los usuarios.

De igual manera verifique que la línea *'ChallengeResponseAuthentication yes'* se encuentre descomentada y si su valor está en 'on' cámbielo por 'yes'.
Así como poner el valor de la línea *'PasswordAuthentication'* en **'no'**.
```bash
ChallengeResponseAuthentication yes
PasswordAuthentication no
```
Por último, comentar la línea **'auth       substack     password-auth'** en el archivo */etc/pam.d/sshd*
```bash
# auth       substack     password-auth
```
Reiniciamos el demonio SSHD **(Importante no salir del servidor por si el demonio no se reinicia correctamente)**
```bash
sudo systemctl restart sshd
```