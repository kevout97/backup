export https_proxy="https://10.0.202.7:8080"
export http_proxy="http://10.0.202.7:8080"

rpm  -Uvh https://copr-be.cloud.fedoraproject.org/archive/spacewalk/2.6-client/RHEL/7/x86_64/rpm -Uvh https://copr-be.cloud.fedoraproject.org/results/@spacewalkproject/spacewalk-2.8-client/epel-7-x86_64/00742644-spacewalk-repo/spacewalk-client-repo-2.8-11.el7.centos.noarch.rpm
rpm -Uvh http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install rhn-client-tools rhn-check rhn-setup rhnsd m2crypto yum-rhn-plugin
rpm -Uvh https://spacewalk.ctin-uat.amxdigital.net/pub/rhn-org-trusted-ssl-cert-1.0-1.noarch.rpm
 6b76c06e8caf45e0733c35c3c8e661e7
cat >foo.sh <<EOF
     Key-Type: RSA
     Key-Length: 4096
     Name-Real: spacewalk
     Name-Comment: hola
     Name-Email: correo@gmail.com
     Expire-Date: 0
     Passphrase: spacewalk
EOF
 gpg --batch --gen-key gen-key-scr

https://access.redhat.com/documentation/es-es/red_hat_satellite/6.0/pdf/user_guide/Red_Hat_Satellite-6.0-User_Guide-es-ES.pdf

https://www.itzgeek.com/how-tos/linux/centos-how-tos/managing-channels-and-repositories-spacewalk-on-centos-7-rhel-7.html


https://www.unixmen.com/how-to-manage-spacewalk-channels-and-repositories/