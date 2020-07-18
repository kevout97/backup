FROM dockeregistry.amovildigitalops.com/rhel7-atomic

MAINTAINER Path patricio@amxiniciativas.com 
LABEL maintainer="Mauricio Meléndez && Kevin Gómez / GADT-AMX"

LABEL Description="PHP 7.0 fpm redis pdo mysql xml json zip db2" Vendor="AMX-SID-GI" Version="2.0"
# fpm n nginx will drop privileges.

USER root

ENV PATH=/sbin:/opt/rh/rh-php72/root/usr/bin:/opt/rh/rh-php72/root/usr/sbin${PATH:+:${PATH}} \
    LD_LIBRARY_PATH=/opt/rh/devtoolset-3/root/usr/lib64/:/opt/rh/rh-php72/root/usr/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}} \
    MANPATH=/opt/rh/rh-php72/root/usr/share/man:${MANPATH}

# Repos
RUN curl https://repos.amxdigital.net/rhel-server-rhscl-7-rpms.repo  -o /etc/yum.repos.d/rhel-server-rhscl-7-rpms.repo && curl https://repos.amxdigital.net/rhel-7-server-rpms.repo -o /etc/yum.repos.d/rhel-7-server-rpms.repo && curl https://repos.amxdigital.net/rhel-7-nginx-rpms.repo  -o /etc/yum.repos.d/rhel-7-nginx-rpms.repo

RUN microdnf install rh-php72 rh-php72-php-bcmath rh-php72-php-fpm rh-php72-php-json rh-php72-php-mysqlnd rh-php72-php-pdo rh-php72-php-soap rh-php72-php-xml rh-php72-php-zip rh-php72-php-gd.x86_64 rh-php72-php-mbstring.x86_64

COPY v11.1.4fp4a_linuxx64_universal_fixpack.tar.gz /root/

# PHP 72 extensions 
RUN mkdir -p /opt/ibm-db2 && export IBM_DB_HOME=/opt/ibm/db2/V11.1 && \
    microdnf install tar && microdnf clean all && \
    tar -xzvf /root/v11.1.4fp4a_linuxx64_universal_fixpack.tar.gz -C /opt/ibm-db2 && \
    microdnf install gcc && microdnf clean all && \
    microdnf install kernel-devel && microdnf clean all && \
    microdnf install gcc-c++ && microdnf clean all && \
    microdnf install cpp && microdnf clean all && \
    microdnf install pam && microdnf clean all && \
    microdnf install numactl-libs && microdnf clean all && \
    microdnf install libaio-devel && microdnf clean all && \
    microdnf install make && microdnf clean all && \
    yes yes | sh /opt/ibm-db2/universal/db2_install -b /opt/ibm/db2/V11.1 -p CLIENT  && \
    microdnf install php-pear && microdnf clean all && \
    microdnf install rh-php72-php-devel && microdnf clean all && \
    pecl install ibm_db2

RUN pecl channel-update pecl.php.net &&  yes no | pecl install redis && microdnf remove \
                autoconf \
                automake \
                cpp \
                gcc \
                gcc-c++\
                gcc kernel-headers \
                glibc-devel \
                glibc-devel \
                glibc-headers \
                kernel-headers \
                libgomp \
                libmpc \ 
                m4 \
                make \
                rh-php72-php-devel \ 
                mpfr \ 
                pcre-devel \
                yum  \ 
                openssl-devel 

RUN mkdir -p /var/www/sites/ /var/cache/php-fpm/ /var/log/php-fpm/ && chown apache:apache /var/cache/php-fpm/ /var/log/php-fpm/

VOLUME ["/var/www/sites","/var/cache/php-fpm/","/var/log/php-fpm/"]

ADD CA/* /etc/pki/ca-trust/source/anchors/

RUN update-ca-trust enable && update-ca-trust extract

ADD php/www.conf /etc/opt/rh/rh-php72/php-fpm.d/

ADD php.ini /etc/opt/rh/rh-php72/

RUN echo -e '; Enable redis extension module\nextension=redis.so' > /etc/opt/rh/rh-php72/php.d/30-redis.ini

RUN echo -e '; Enable ibm_db2 extension module\nextension=ibm_db2.so' > /etc/opt/rh/rh-php72/php.d/30-db2-ibm.ini

ADD docker-entrypoint.sh /sbin/docker-entrypoint.sh

ENTRYPOINT ["/sbin/docker-entrypoint.sh"]
