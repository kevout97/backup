# Agregar usuario
### OPEN SUSE
##### Instalación de paquetes
```bash
zypper ar -f http://download.opensuse.org/repositories/systemsmanagement:/spacewalk:/2.8/openSUSE_Tumbleweed/ spacewalk-tools
zypper install rhn-client-tools zypp-plugin-spacewalk rhnsd rhn-setup rhn-check
```
##### Obetención de certificado
Estructura  wget http://YourSpacewalk.example.org/pub/RHN-ORG-TRUSTED-SSL-CERT -O /usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT
```bash
 wget http://spacewalk.ctin-uat.amxdigital.net/pub/RHN-ORG-TRUSTED-SSL-CERT -O /usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT
 ln -s /usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT /usr/share/pki/trust/anchors/RHN-ORG-TRUSTED-SSL-CERT.pem
```
##### Registro de usuario
Estructura: rhnreg_ks --serverUrl=https://YourSpacewalk.example.org/XMLRPC --sslCACert=/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT --activationkey=<key-with-SUSE-custom-channel> 
```bash
rhnreg_ks --force --serverUrl=http://spacewalk.ctin-uat.amxdigital.net/XMLRPC --sslCACert=/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT --activationkey=1-c39c0d5bf596e3474f921c38fbd1881b
```

#### FEDORA 
##### Instalación de paquetes
```bash
dnf copr enable @spacewalkproject/spacewalk-2.8-client
dnf -y install rhn-client-tools rhn-check rhn-setup rhnsd m2crypto dnf-plugin-spacewalk
```
##### Obetención de certificado
Estructura:  rpm -Uhv  http://MY-SPACEWALK/pub/rhn-org-trusted-ssl-cert-1.0-1.noarch.rpm

```bash
rpm -Uhv  https://spacewalk.azure.net/pub/rhn-org-trusted-ssl-cert-1.0-1.noarch.rpm
```
##### Registro de usuario
Estructura:  rhnreg_ks  --serverUrl=http://MY-SPACEWALK/XMLRPC  --sslCACert=/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT  --activationkey=No.CANAL-CLAVE
```bash
rhnreg_ks --force --serverUrl=https://spacewalk.azure.net/XMLRPC --sslCACert=/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT --activationkey=1-c39c0d5bf596e3474f921c38fbd1881b
```

#### Red Hat Enterprise Linux 5, 6 y 7, Scientific Linux 6 and 7, CentOS 5, 6 y 7
```bash
rpm -Uvh https://copr-be.cloud.fedoraproject.org/results/@spacewalkproject/spacewalk-2.8-client/epel-7-x86_64/00742644-spacewalk-repo/spacewalk-client-repo-2.8-11.el7.centos.noarch.rpm
rpm -Uvh http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install rhn-client-tools rhn-check rhn-setup rhnsd m2crypto yum-rhn-plugin
```
##### Obetención de certificado
Estructura:  rpm -Uhv  http://MY-SPACEWALK/pub/rhn-org-trusted-ssl-cert-1.0-1.noarch.rpm
```bash
rpm -Uhv  https://spacewalk.azure.net/pub/rhn-org-trusted-ssl-cert-1.0-1.noarch.rpm
```
##### Registro de usuario
Estructura:  rhnreg_ks  --serverUrl=http://MY-SPACEWALK/XMLRPC  --sslCACert=/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT  --activationkey=No.CANAL-CLAVE
```bash
rhnreg_ks --force --serverUrl=https://spacewalk.azure.net/XMLRPC --sslCACert=/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT --activationkey=1-c39c0d5bf596e3474f921c38fbd1881b
```
#### PROXY 
Modificar el archivo /etc/sysconfig/rhn/up2date
* Agrega el nombre del servidor

```bash 
serverURL[comment]=Remote server URL (use FQDN)
serverURL=https://spacewalk.azure.net/XMLRPC
```
* Habilita el uso de proxy 

```bash
enableProxy[comment]=Use a HTTP Proxy
enableProxy=1
```
* Agrega el servidor proxy  

```bash
httpProxy[comment]=HTTP proxy in host:port format, e.g. squid.redhat.com:3128
httpProxy=10.0.202.7:8080
```
#### Archivo de configuración
/etc/sysconfig/rhn/up2date

#### COMANDOS REMOTOS
Para poder realizar comandos remotos se debe instalar el RPM rhncfg-actions en el cliente de spacewalk y habilitar esta funciòn. 
```bash
yum install -y rhncfg-actions
rhn-actions-control --enable-run
```
yum install osad
service osad start

#### COMANDOS 
rpm -e rhn-org-trusted-ssl-cert-1.0-1.noarch&nbsp;
rhn_check -vvvv
#### PRUEBAS

rpm -Uhv  http://40.86.219.67/pub/rhn-org-trusted-ssl-cert-1.0-1.noarch.rpm
rhnreg_ks --force --serverUrl=http://40.86.219.67/XMLRPC --sslCACert=/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT --activationkey=1-17f8f8ba0ccb07a74a9a50500baee9a1

https://40.86.219.67/rhn/YourRhn.do

rpm -Uhv  https://40.86.219.67/pub/rhn-org-trusted-ssl-cert-1.0-1.noarch.rpm

17f8f8ba0ccb07a74a9a50500baee9a1

#### Dar de baja o deshabilitar a cliente. Eliminar configuración del servidor en el cliente.
```bash
 yum remove rhn* osad spacewalk* yum-rhn-plugin
``` 
Deshabilitar 
```bash
 systemctl disable rhnsd
 systemctl disable rhnmd
 sed -i 's/enabled *= *1/enabled=0/' /etc/yum/pluginconf.d/rhnplugin.conf
``` 
##### Referencias
* https://www.redhat.com/archives/spacewalk-list/2009-February/msg00368.html
* https://access.redhat.com/solutions/15753
https://serverfault.com/questions/411262/spacewalk-dosent-install-package-unless-rhn-check-excuted-on-client
#### STUFFS 

* ct1n1nfr4
* ssh laurencio_galicia@40.86.219.67



