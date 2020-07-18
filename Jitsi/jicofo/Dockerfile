FROM dockeregistry.amovildigitalops.com/rhel7-atomic

USER root

ENV PATH $PATH:/opt/apache-maven-3.6.3/bin

RUN curl https://repos.amxdigital.net/rhui-rhel-7-server-rhui-rpms.repo  -o /etc/yum.repos.d/rhui-rhel-7-server-rhui-rpms.repo && \
	curl https://repos.amxdigital.net/rhui-rhel-server-rhui-rhscl-7-rpms.repo -o /etc/yum.repos.d/rhui-rhel-server-rhui-rhscl-7-rpms.repo && \
    curl https://repos.amxdigital.net/rhel-server-rhscl-7-rpms.repo -o rhel-server-rhscl-7-rpms.repo \
    && curl https://repos.amxdigital.net/rhel-7-server-rpms.repo -o rhel-7-server-rpms.repo  \
    && curl https://repos.amxdigital.net/rhui-rhel-7-server-rhui-optional-rpms.repo -o rhui-rhel-7-server-rhui-optional-rpms.repo \
    && curl https://repos.amxdigital.net/rhel-7-server-extras-rpms.repo -o rhel-7-server-extras-rpms.repo && \
    microdnf install tar git unzip gcc openssl java-1.8.0-openjdk-devel -y

RUN curl -O https://downloads.apache.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz && \
    tar -xzvf apache-maven-3.6.3-bin.tar.gz -C /opt && \
    rm -f apache-maven-3.6.3-bin.tar.gz && \
    git clone https://github.com/jitsi/jicofo.git /opt/jicofo

ENV JAVA_HOME /usr/lib/jvm/java-openjdk

RUN cd /opt/jicofo && \
    mvn package -DskipTests -Dassembly.skipAssembly=false && \
    unzip target/jicofo-1.1-SNAPSHOT-archive.zip && \
    ln -s /opt/jicofo/jicofo-1.1-SNAPSHOT/jicofo.sh /usr/bin/jicofo

COPY docker-entrypoint.sh /sbin/

RUN chmod 777 /sbin/docker-entrypoint.sh && \
    echo "jicofo:x:1001:1001:Jitsi Jicofo:/opt/jicofo/jicofo-1.1-SNAPSHOT/:/sbin/nologin" >> /etc/passwd && \
    mkdir -p /etc/jitsi/jicofo/ && \
    mkdir -p /var/log/jitsi && \
    echo "IyBKaXRzaSBDb25mZXJlbmNlIEZvY3VzIHNldHRpbmdzCiMgc2V0cyB0aGUgaG9zdCBuYW1lIG9mIHRoZSBYTVBQIHNlcnZlcgpKSUNPRk9fSE9TVD1sb2NhbGhvc3QKCiMgc2V0cyB0aGUgWE1QUCBkb21haW4gKGRlZmF1bHQ6IG5vbmUpCkpJQ09GT19IT1NUTkFNRT1jbGFyb2Nvbm5lY3QuY29tCgojIHNldHMgdGhlIHNlY3JldCB1c2VkIHRvIGF1dGhlbnRpY2F0ZSBhcyBhbiBYTVBQIGNvbXBvbmVudApKSUNPRk9fU0VDUkVUPXhQNmZnVSNsCgojIHNldHMgdGhlIHBvcnQgdG8gdXNlIGZvciB0aGUgWE1QUCBjb21wb25lbnQgY29ubmVjdGlvbgpKSUNPRk9fUE9SVD01MzQ3CgojIHNldHMgdGhlIFhNUFAgZG9tYWluIG5hbWUgdG8gdXNlIGZvciBYTVBQIHVzZXIgbG9naW5zCkpJQ09GT19BVVRIX0RPTUFJTj1hdXRoLmNsYXJvY29ubmVjdC5jb20KCiMgc2V0cyB0aGUgdXNlcm5hbWUgdG8gdXNlIGZvciBYTVBQIHVzZXIgbG9naW5zCkpJQ09GT19BVVRIX1VTRVI9Zm9jdXMKCiMgc2V0cyB0aGUgcGFzc3dvcmQgdG8gdXNlIGZvciBYTVBQIHVzZXIgbG9naW5zCkpJQ09GT19BVVRIX1BBU1NXT1JEPWZhOERtR1FrCgojIGV4dHJhIG9wdGlvbnMgdG8gcGFzcyB0byB0aGUgamljb2ZvIGRhZW1vbgpKSUNPRk9fT1BUUz0iIgoKIyBhZGRzIGphdmEgc3lzdGVtIHByb3BzIHRoYXQgYXJlIHBhc3NlZCB0byBqaWNvZm8gKGRlZmF1bHQgYXJlIGZvciBob21lIGFuZCBsb2dnaW5nIGNvbmZpZyBmaWxlKQpKQVZBX1NZU19QUk9QUz0iLURuZXQuamF2YS5zaXAuY29tbXVuaWNhdG9yLlNDX0hPTUVfRElSX0xPQ0FUSU9OPS9ldGMvaml0c2kgLURuZXQuamF2YS5zaXAuY29tbXVuaWNhdG9yLlNDX0hPTUVfRElSX05BTUU9amljb2ZvIC1EbmV0LmphdmEuc2lwLmNvbW11bmljYXRvci5TQ19MT0dfRElSX0xPQ0FUSU9OPS92YXIvbG9nL2ppdHNpIC1EamF2YS51dGlsLmxvZ2dpbmcuY29uZmlnLmZpbGU9L2V0Yy9qaXRzaS9qaWNvZm8vbG9nZ2luZy5wcm9wZXJ0aWVzIgo=" | base64 -w0 -d > /etc/jitsi/jicofo/config && \
    echo "CmhhbmRsZXJzPSBqYXZhLnV0aWwubG9nZ2luZy5Db25zb2xlSGFuZGxlcgoKIyBIYW5kbGVycyB3aXRoIFhNUFAgZGVidWcgZW5hYmxlZDoKI2hhbmRsZXJzPSBqYXZhLnV0aWwubG9nZ2luZy5Db25zb2xlSGFuZGxlciwgb3JnLmppdHNpLmltcGwucHJvdG9jb2wueG1wcC5sb2cuWG1wcFBhY2tldHNGaWxlSGFuZGxlcgoKIyBIYW5kbGVycyB3aXRoIHN5c2xvZyBlbmFibGVkOgojaGFuZGxlcnM9IGphdmEudXRpbC5sb2dnaW5nLkNvbnNvbGVIYW5kbGVyLCBjb20uYWdhZnVhLnN5c2xvZy5TeXNsb2dIYW5kbGVyCgpqYXZhLnV0aWwubG9nZ2luZy5Db25zb2xlSGFuZGxlci5sZXZlbCA9IEFMTApqYXZhLnV0aWwubG9nZ2luZy5Db25zb2xlSGFuZGxlci5mb3JtYXR0ZXIgPSBuZXQuamF2YS5zaXAuY29tbXVuaWNhdG9yLnV0aWwuU2NMb2dGb3JtYXR0ZXIKamF2YS51dGlsLmxvZ2dpbmcuQ29uc29sZUhhbmRsZXIuZmlsdGVyID0gb3JnLmppdHNpLmltcGwucHJvdG9jb2wueG1wcC5sb2cuRXhjbHVkZVhtcHBQYWNrZXRzCgpuZXQuamF2YS5zaXAuY29tbXVuaWNhdG9yLnV0aWwuU2NMb2dGb3JtYXR0ZXIucHJvZ3JhbW5hbWU9Smljb2ZvCgoubGV2ZWw9SU5GTwpuZXQuc2YubGV2ZWw9U0VWRVJFCm5ldC5qYXZhLnNpcC5jb21tdW5pY2F0b3IucGx1Z2luLnJlY29ubmVjdHBsdWdpbi5sZXZlbD1GSU5FCm9yZy5pY2U0ai5sZXZlbD1TRVZFUkUKb3JnLmppdHNpLmltcGwubmVvbWVkaWEubGV2ZWw9U0VWRVJFCgojIERvIG5vdCB3b3JyeSBhYm91dCBtaXNzaW5nIHN0cmluZ3MKbmV0LmphdmEuc2lwLmNvbW11bmljYXRvci5zZXJ2aWNlLnJlc291cmNlcy5BYnN0cmFjdFJlc291cmNlc1NlcnZpY2UubGV2ZWw9U0VWRVJFCgojbmV0LmphdmEuc2lwLmNvbW11bmljYXRvci5zZXJ2aWNlLnByb3RvY29sLmxldmVsPUFMTAoKIyBUbyBlbmFibGUgWE1QUCBwYWNrZXRzIGxvZ2dpbmcgYWRkIFhtcHBQYWNrZXRzRmlsZUhhbmRsZXIgdG8gdGhlIGhhbmRsZXJzIHByb3BlcnR5Cm9yZy5qaXRzaS5pbXBsLnByb3RvY29sLnhtcHAubG9nLlBhY2tldERlYnVnZ2VyLmxldmVsPUFMTApvcmcuaml0c2kuaW1wbC5wcm90b2NvbC54bXBwLmxvZy5YbXBwUGFja2V0c0ZpbGVIYW5kbGVyLnBhdHRlcm49L3Zhci9sb2cvaml0c2kvamljb2ZvLXhtcHAubG9nCm9yZy5qaXRzaS5pbXBsLnByb3RvY29sLnhtcHAubG9nLlhtcHBQYWNrZXRzRmlsZUhhbmRsZXIuYXBwZW5kPXRydWUKb3JnLmppdHNpLmltcGwucHJvdG9jb2wueG1wcC5sb2cuWG1wcFBhY2tldHNGaWxlSGFuZGxlci5saW1pdD0yMDAwMDAwMDAKb3JnLmppdHNpLmltcGwucHJvdG9jb2wueG1wcC5sb2cuWG1wcFBhY2tldHNGaWxlSGFuZGxlci5jb3VudD0zCgojIFN5c2xvZyh1bmNvbW1lbnQgaGFuZGxlciB0byB1c2UpCmNvbS5hZ2FmdWEuc3lzbG9nLlN5c2xvZ0hhbmRsZXIudHJhbnNwb3J0ID0gdWRwCmNvbS5hZ2FmdWEuc3lzbG9nLlN5c2xvZ0hhbmRsZXIuZmFjaWxpdHkgPSBsb2NhbDAKY29tLmFnYWZ1YS5zeXNsb2cuU3lzbG9nSGFuZGxlci5wb3J0ID0gNTE0CmNvbS5hZ2FmdWEuc3lzbG9nLlN5c2xvZ0hhbmRsZXIuaG9zdG5hbWUgPSBsb2NhbGhvc3QKY29tLmFnYWZ1YS5zeXNsb2cuU3lzbG9nSGFuZGxlci5mb3JtYXR0ZXIgPSBuZXQuamF2YS5zaXAuY29tbXVuaWNhdG9yLnV0aWwuU2NMb2dGb3JtYXR0ZXIKY29tLmFnYWZ1YS5zeXNsb2cuU3lzbG9nSGFuZGxlci5lc2NhcGVOZXdsaW5lcyA9IGZhbHNlCmNvbS5hZ2FmdWEuc3lzbG9nLlN5c2xvZ0hhbmRsZXIuZmlsdGVyID0gb3JnLmppdHNpLmltcGwucHJvdG9jb2wueG1wcC5sb2cuRXhjbHVkZVhtcHBQYWNrZXRzCgojIHRvIGRpc2FibGUgZG91YmxlIHRpbWVzdGFtcHMgaW4gc3lzbG9nIHVuY29tbWVudCBuZXh0IGxpbmUKI25ldC5qYXZhLnNpcC5jb21tdW5pY2F0b3IudXRpbC5TY0xvZ0Zvcm1hdHRlci5kaXNhYmxlVGltZXN0YW1wPXRydWUKCiMgdW5jb21tZW50IHRvIHNlZSBob3cgSmljb2ZvIHRhbGtzIHRvIHRoZSBKVkIKI29yZy5qaXRzaS5pbXBsLnByb3RvY29sLnhtcHAuY29saWJyaS5sZXZlbD1BTEwK" | base64 -w0 -d > /etc/jitsi/jicofo/logging.properties && \
      echo "b3JnLmppdHNpLmppY29mby5CUklER0VfTVVDPUp2YkJyZXdlcnlAaW50ZXJuYWwuYXV0aC5jbGFyb2Nvbm5lY3QuY29t" | base64 -w0 -d > /etc/jitsi/jicofo/sip-communicator.properties && \
     chown 1001:0 -R /etc/jitsi && \
     chown 1001:0 -R /var/log/jitsi && \
     chown 1001:0 -R /opt/jicofo

USER jicofo

ENTRYPOINT ["/sbin/docker-entrypoint.sh"]