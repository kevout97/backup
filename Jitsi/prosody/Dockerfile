FROM debian:stretch

USER root

RUN apt-get update && \
    apt-get install git curl gcc make m4 lua5.2 liblua5.2-dev libsasl2-dev luarocks openssl libssl1.0-dev -y && \
    luarocks install cyrussasl 1.1.0-1 && \
    luarocks install lua-cjson 2.1.0-1 && \
    luarocks install luajwtjitsi 1.3-7 && \
    luarocks install net-url 0.9-1 && \
    luarocks install luasocket 3.0-rc1 && \
    luarocks install luasec 0.7.1 && \
    luarocks install http

RUN apt-get update && apt-get install gnupg2 wget -y && \
    echo "deb http://packages.prosody.im/debian stretch main" > /etc/apt/sources.list.d/prosody.list && \
    wget https://prosody.im/files/prosody-debian-packages.key -O- | apt-key add - && \
    apt-get install prosody -y && \
    apt-get update && apt-get upgrade prosody -y && \
    curl -o /usr/lib/prosody/modules/mod_auth_ldap.lua https://raw.githubusercontent.com/prosody-modules/mod_auth_ldap/master/mod_auth_ldap.lua && \
    curl -o /usr/lib/prosody/modules/mod_carbons.lua https://hg.prosody.im/prosody-modules/raw-file/tip/mod_carbons/mod_carbons.lua && \
    git clone https://github.com/jitsi/jitsi-meet.git /opt/jitsi-prosody && \
    cp -f /opt/jitsi-prosody/resources/prosody-plugins/*.lua /usr/lib/prosody/modules/ && \
    rm -rf /opt/jitsi-prosody

COPY docker-entrypoint.sh /sbin/docker-entrypoint.sh

RUN rm -f /etc/prosody/prosody.cfg.lua /etc/prosody/prosody.cfg.lua.dist && \
    mkdir -p /etc/prosody/conf.d && \
    mkdir -p /etc/prosody/certs && \
    mkdir -p /usr/share/claro-jitsi-meet && \
    chown prosody:prosody -R /etc/prosody && \
    chmod 777 /sbin/docker-entrypoint.sh

COPY prosody.cfg.lua /etc/prosody/prosody.cfg.lua

COPY claro-jitsi-meet /usr/share/claro-jitsi-meet

RUN chown prosody:prosody -R /usr/share/claro-jitsi-meet && \
    chown prosody:prosody /etc/prosody/prosody.cfg.lua && \
    mkdir -p  /var/run/prosody && \
    chown prosody:prosody -R /var/run/prosody

USER prosody

ENTRYPOINT ["/sbin/docker-entrypoint.sh"]

EXPOSE 5222 5347 5280