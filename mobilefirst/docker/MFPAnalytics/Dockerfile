FROM dockeregistry.amovildigitalops.com/rhel7-atomic
LABEL maintainer="Kevin Gómez & Mauricio Meléndez / AMX GA"

RUN curl https://repos.amxdigital.net/rhel-server-rhscl-7-rpms.repo  -o /etc/yum.repos.d/rhel-server-rhscl-7-rpms.repo && curl https://repos.amxdigital.net/rhel-7-server-rpms.repo -o /etc/yum.repos.d/rhel-7-server-rpms.repo

RUN microdnf update && microdnf clean all\
	&& microdnf install -y \
    unzip \
    wget \
    curl \
    vi \
    tar \
    net-tools \
    openssh-server

RUN wget https://nexus.san.gadt.amxdigital.net/repository/cloud/amx/IBM_MOBILEFIRST_PLATFORM_FOUNDATI.zip -P / \
    && mkdir -p /MobileFirst \
    && unzip /IBM_MOBILEFIRST_PLATFORM_FOUNDATI.zip -d /MobileFirst \
    && rm -f IBM_MOBILEFIRST_PLATFORM_FOUNDATI.zip

# Expose port 54328: The elastic search transport port for multicast  
EXPOSE 54328
  
ENV JAVA_HOME /opt/ibm/ibm-java-x86_64-80
ENV LICENSE accept

# SSH
RUN mkdir -p /var/run/sshd &&\
    mkdir -p /root/.ssh/ &&\
    mkdir -p /root/sshkey/ &&\
    touch /root/.ssh/authorized_keys &&\
    sed -i 's/session \+required \+pam_loginuid\.so/session optional pam_loginuid.so/' /etc/pam.d/sshd &&\
    sed -i 's/.*PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config &&\
    sed -i 's/.*UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config &&\
    sed -i 's/.*ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/g' /etc/ssh/sshd_config

# Set password length and expiry for compliance with Vulnerability Advisor (mantener)
RUN sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs \
    && sed -i 's/sha512/sha512  minlen=8/' /etc/pam.d/system-auth

COPY entrypoint.sh /root
RUN chmod +x /root/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh" ]