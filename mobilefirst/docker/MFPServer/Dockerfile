FROM dockeregistry.amovildigitalops.com/rhel7-atomic
LABEL maintainer="Mauricio Melendez & Kevin Gómez / AMX GA"

USER root

RUN curl https://repos.amxdigital.net/rhel-server-rhscl-7-rpms.repo  -o /etc/yum.repos.d/rhel-server-rhscl-7-rpms.repo && curl https://repos.amxdigital.net/rhel-7-server-rpms.repo -o /etc/yum.repos.d/rhel-7-server-rpms.repo

RUN microdnf update -y \
    && microdnf install -y \
    wget \
    curl \
    net-tools \
    vi \
    openssh-server \
    iputils \
    hostname \
    unzip

COPY IBM_MOBILEFIRST_PLATFORM_FOUNDATI.zip /

RUN mkdir -p /MobileFirst \
    && unzip /IBM_MOBILEFIRST_PLATFORM_FOUNDATI.zip -d /MobileFirst \
    && rm -f IBM_MOBILEFIRST_PLATFORM_FOUNDATI.zip


# Install JRE

ADD dependencies/ibm-java-jre-8.0-5.17-linux-x86_64_*.tgz /opt/ibm/    
ENV JAVA_HOME /opt/ibm/ibm-java-x86_64-80

COPY dependencies/license-check /opt/ibm/docker/
COPY dependencies/ibm.com_IBM_MobileFirst_Platform_Foundation-8.0.0.swidtag /opt/ibm/MobileFirst/swidtag/


# Install WebSphere Liberty
ADD dependencies/wlp-base-embeddable-18.0.0.2_*.tar.gz /opt/ibm/

# Create 'mfp' profile
RUN /opt/ibm/wlp/bin/server create mfp \
    && rm -rf /opt/ibm/wlp/usr/servers/.classCache \
    && rm -rf /opt/ibm/wlp/usr/servers/mfp/apps/* \
    && mkdir -p /opt/ibm/MobileFirst/licenses 
    
# SSH
RUN mkdir -p /var/run/sshd &&\
    mkdir -p /root/.ssh/ &&\
    mkdir -p /root/sshkey/ &&\
    touch /root/.ssh/authorized_keys &&\
    sed -i 's/session \+required \+pam_loginuid\.so/session optional pam_loginuid.so/' /etc/pam.d/sshd &&\
    sed -i 's/.*PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config &&\
    sed -i 's/.*UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config &&\
    sed -i 's/.*ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/g' /etc/ssh/sshd_config

ADD mfpf-libs/mfpf-server-containers.tgz /
ADD mfpf-libs/mfpf-server-common.tgz /opt/ibm/
COPY licenses/ /opt/ibm/MobileFirst/licenses

# Set password length and expiry for compliance with Vulnerability Advisor
RUN sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs \
     && sed -i 's/sha512/sha512  minlen=8/' /etc/pam.d/system-auth

RUN useradd syslog \
    && chmod u+x /opt/ibm/docker/license-check \
    && chmod u+x /opt/ibm/wlp/bin/liberty-run \
    && chmod +x /root/bin/run_supervisord \
    && mkdir /var/log/rsyslog \
    && chown syslog /var/log/rsyslog

ENV LICENSE accept

COPY entrypoint.sh /sbin
RUN chmod +x /sbin/entrypoint.sh
COPY docker-health-check.sh /sbin
RUN chmod +x /sbin/docker-health-check.sh
ENTRYPOINT [ "/sbin/entrypoint.sh" ]

COPY usr/bin/mfp-init /opt/ibm/wlp/bin/
RUN chmod u+x /opt/ibm/wlp/bin/mfp-init
COPY usr/security /opt/ibm/wlp/usr/servers/mfp/resources/security/
COPY usr/jre-security /opt/ibm/ibm-java-x86_64-80/jre/lib/security/
COPY usr/env /opt/ibm/wlp/usr/servers/mfp/
COPY usr/ssh /root/sshkey/
COPY usr/wxs /opt/ibm/wlp/
COPY usr/config/*.xml /opt/ibm/wlp/usr/servers/mfp/configDropins/overrides/