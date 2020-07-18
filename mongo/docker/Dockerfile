FROM dockeregistry.amovildigitalops.com/rhel7-atomic
LABEL maintainer="Mauricio Meléndez && Kevin Gómez / GADT-AMX"

RUN echo 'export PS1="[\u@\h \W]\$"' >> /root/.bash_profile && source /root/.bash_profile && \
    echo 'W21vbmdvZGItb3JnLTQuMl0KbmFtZT1Nb25nb0RCIFJlcG9zaXRvcnkKYmFzZXVybD1odHRwczovL3JlcG8ubW9uZ29kYi5vcmcveXVtL3JlZGhhdC8kcmVsZWFzZXZlci9tb25nb2RiLW9yZy80LjIveDg2XzY0LwpncGdjaGVjaz0wCmVuYWJsZWQ9MQpncGdrZXk9aHR0cHM6Ly93d3cubW9uZ29kYi5vcmcvc3RhdGljL3BncC9zZXJ2ZXItNC4yLmFzYwo=' | base64 -w0 -d > /etc/yum.repos.d/mongodb.repo && \
    curl https://repos.amxdigital.net/rhel-server-rhscl-7-rpms.repo  -o /etc/yum.repos.d/rhel-server-rhscl-7-rpms.repo && curl https://repos.amxdigital.net/rhel-7-server-rpms.repo -o /etc/yum.repos.d/rhel-7-server-rpms.repo && \
    echo "mongod:x:1337:1337:mongod Service:/home/mongod:/sbin/nologin" >> /etc/passwd

RUN microdnf install mongodb-org -y && microdnf clean all && mkdir -p /data/db && \
    mkdir -p /var/log/mongodb/ && touch /var/log/mongodb/mongod.log && \
    chown 1337:1337 -R /var/lib/mongo && \
    echo "IyBtb25nb2QuY29uZgoKIyBmb3IgZG9jdW1lbnRhdGlvbiBvZiBhbGwgb3B0aW9ucywgc2VlOgojICAgaHR0cDovL2RvY3MubW9uZ29kYi5vcmcvbWFudWFsL3JlZmVyZW5jZS9jb25maWd1cmF0aW9uLW9wdGlvbnMvCgojIHdoZXJlIHRvIHdyaXRlIGxvZ2dpbmcgZGF0YS4Kc3lzdGVtTG9nOgogIGRlc3RpbmF0aW9uOiBmaWxlCiAgbG9nQXBwZW5kOiB0cnVlCiAgcGF0aDogL3Zhci9sb2cvbW9uZ29kYi9tb25nb2QubG9nCgojIFdoZXJlIGFuZCBob3cgdG8gc3RvcmUgZGF0YS4Kc3RvcmFnZToKICBkYlBhdGg6IC92YXIvbGliL21vbmdvCiAgam91cm5hbDoKICAgIGVuYWJsZWQ6IHRydWUKIyAgZW5naW5lOgojICB3aXJlZFRpZ2VyOgoKIyBob3cgdGhlIHByb2Nlc3MgcnVucwpwcm9jZXNzTWFuYWdlbWVudDoKICBmb3JrOiB0cnVlICAjIGZvcmsgYW5kIHJ1biBpbiBiYWNrZ3JvdW5kCiAgcGlkRmlsZVBhdGg6IC92YXIvcnVuL21vbmdvZGIvbW9uZ29kLnBpZCAgIyBsb2NhdGlvbiBvZiBwaWRmaWxlCiAgdGltZVpvbmVJbmZvOiAvdXNyL3NoYXJlL3pvbmVpbmZvCgojIG5ldHdvcmsgaW50ZXJmYWNlcwpuZXQ6CiAgcG9ydDogMjcwMTcKICBiaW5kSXA6IDAuMC4wLjAgICMgRW50ZXIgMC4wLjAuMCw6OiB0byBiaW5kIHRvIGFsbCBJUHY0IGFuZCBJUHY2IGFkZHJlc3NlcyBvciwgYWx0ZXJuYXRpdmVseSwgdXNlIHRoZSBuZXQuYmluZElwQWxsIHNldHRpbmcuCgoKI3NlY3VyaXR5OgoKI29wZXJhdGlvblByb2ZpbGluZzoKCiNyZXBsaWNhdGlvbjoKCiNzaGFyZGluZzoKCiMjIEVudGVycHJpc2UtT25seSBPcHRpb25zCgojYXVkaXRMb2c6Cgojc25tcDo=" | base64 -w0 -d  > /etc/mongod.conf && \
    chown 1337 /etc/mongod.conf && \
    mkdir /home/mongod && \
    chown 1337 /home/mongod

EXPOSE 27017

COPY docker-entrypoint.sh /sbin/
RUN  chmod +x /sbin/docker-entrypoint.sh
USER mongod
ENTRYPOINT [ "/sbin/docker-entrypoint.sh" ]