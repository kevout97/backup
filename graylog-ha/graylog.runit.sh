#!/bin/bash

#####################################################
#                                                   #
#                Runit Graylog 3.2                  #
#                                                   #
#####################################################

## Despliegue de Mongo
MONGO_CONTAINER="graylog-mongo"
mkdir -p /var/containers/$MONGO_CONTAINER/data/db
chown 999:0 -R /var/containers/$MONGO_CONTAINER/data/db

docker run -td --name $MONGO_CONTAINER \
    -v /var/containers/$MONGO_CONTAINER/data/db:/data/db:z \
    -v /etc/localtime:/etc/localtime:ro \
    -e TZ=America/Mexico_City \
    --restart unless-stopped \
    -d mongo:3

## Despliegue de Elastic

## Despliegue de Graylog
GRAYLOG_CONTAINER="graylog"
mkdir -p /var/containers/$GRAYLOG_CONTAINER/usr/share/graylog/data/{journal,config}

echo 'PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPENvbmZpZ3VyYXRpb24gcGFja2FnZXM9Im9yZy5ncmF5bG9nMi5sb2c0aiI+CiAgICA8QXBwZW5kZXJzPgogICAgICAgIDxDb25zb2xlIG5hbWU9IlNURE9VVCIgdGFyZ2V0PSJTWVNURU1fT1VUIj4KICAgICAgICAgICAgPFBhdHRlcm5MYXlvdXQgcGF0dGVybj0iJWQgJS01cDogJWMgLSAlbSVuIi8+CiAgICAgICAgPC9Db25zb2xlPgoKICAgICAgICA8IS0tIEludGVybmFsIEdyYXlsb2cgbG9nIGFwcGVuZGVyLiBQbGVhc2UgZG8gbm90IGRpc2FibGUuIFRoaXMgbWFrZXMgaW50ZXJuYWwgbG9nIG1lc3NhZ2VzIGF2YWlsYWJsZSB2aWEgUkVTVCBjYWxscy4gLS0+CiAgICAgICAgPE1lbW9yeSBuYW1lPSJncmF5bG9nLWludGVybmFsLWxvZ3MiIGJ1ZmZlclNpemU9IjUwMCIvPgogICAgPC9BcHBlbmRlcnM+CiAgICA8TG9nZ2Vycz4KICAgICAgICA8IS0tIEFwcGxpY2F0aW9uIExvZ2dlcnMgLS0+CiAgICAgICAgPExvZ2dlciBuYW1lPSJvcmcuZ3JheWxvZzIiIGxldmVsPSJpbmZvIi8+CiAgICAgICAgPExvZ2dlciBuYW1lPSJjb20uZ2l0aHViLmpvc2NoaS5qYWRjb25maWciIGxldmVsPSJ3YXJuIi8+CiAgICAgICAgPCEtLSB0aGlzIGVtaXRzIGEgaGFybWxlc3Mgd2FybmluZyBmb3IgQWN0aXZlRGlyZWN0b3J5IGV2ZXJ5IHRpbWUgd2hpY2ggd2UgY2FuJ3Qgd29yayBhcm91bmQgOiggLS0+CiAgICAgICAgPExvZ2dlciBuYW1lPSJvcmcuYXBhY2hlLmRpcmVjdG9yeS5hcGkubGRhcC5tb2RlbC5tZXNzYWdlLkJpbmRSZXF1ZXN0SW1wbCIgbGV2ZWw9ImVycm9yIi8+CiAgICAgICAgPCEtLSBQcmV2ZW50IERFQlVHIG1lc3NhZ2UgYWJvdXQgTHVjZW5lIEV4cHJlc3Npb25zIG5vdCBmb3VuZC4gLS0+CiAgICAgICAgPExvZ2dlciBuYW1lPSJvcmcuZWxhc3RpY3NlYXJjaC5zY3JpcHQiIGxldmVsPSJ3YXJuIi8+CiAgICAgICAgPCEtLSBEaXNhYmxlIG1lc3NhZ2VzIGZyb20gdGhlIHZlcnNpb24gY2hlY2sgLS0+CiAgICAgICAgPExvZ2dlciBuYW1lPSJvcmcuZ3JheWxvZzIucGVyaW9kaWNhbC5WZXJzaW9uQ2hlY2tUaHJlYWQiIGxldmVsPSJvZmYiLz4KICAgICAgICA8IS0tIFN1cHByZXNzIGNyYXp5IGJ5dGUgYXJyYXkgZHVtcCBvZiBEcm9vbHMgLS0+CiAgICAgICAgPExvZ2dlciBuYW1lPSJvcmcuZHJvb2xzLmNvbXBpbGVyLmtpZS5idWlsZGVyLmltcGwuS2llUmVwb3NpdG9yeUltcGwiIGxldmVsPSJ3YXJuIi8+CiAgICAgICAgPCEtLSBTaWxlbmNlIGNoYXR0eSBuYXR0eSAtLT4KICAgICAgICA8TG9nZ2VyIG5hbWU9ImNvbS5qb2VzdGVsbWFjaC5uYXR0eS5QYXJzZXIiIGxldmVsPSJ3YXJuIi8+CiAgICAgICAgPCEtLSBTaWxlbmNlIEthZmthIGxvZyBjaGF0dGVyIC0tPgogICAgICAgIDxMb2dnZXIgbmFtZT0ia2Fma2EubG9nLkxvZyIgbGV2ZWw9Indhcm4iLz4KICAgICAgICA8TG9nZ2VyIG5hbWU9ImthZmthLmxvZy5PZmZzZXRJbmRleCIgbGV2ZWw9Indhcm4iLz4KICAgICAgICA8Um9vdCBsZXZlbD0id2FybiI+CiAgICAgICAgICAgIDxBcHBlbmRlclJlZiByZWY9IlNURE9VVCIvPgogICAgICAgICAgICA8QXBwZW5kZXJSZWYgcmVmPSJncmF5bG9nLWludGVybmFsLWxvZ3MiLz4KICAgICAgICA8L1Jvb3Q+CiAgICA8L0xvZ2dlcnM+CjwvQ29uZmlndXJhdGlvbj4K' | \
    base64 -w0 -d > /var/containers/$GRAYLOG_CONTAINER/usr/share/graylog/data/config/log4j2.xml

chown 1100:0 -R /var/containers/$GRAYLOG_CONTAINER/usr/share/graylog/data/


docker run  -td --name $GRAYLOG_CONTAINER \
    -h graylog.san.gadt.amxdigital.net \
    --ulimit nproc=1048576:1048576 \
    --restart unless-stopped \
    -v /etc/localtime:/etc/localtime:ro \
    -v /var/containers/$GRAYLOG_CONTAINER/usr/share/graylog/data/journal:/usr/share/graylog/data/journal:z \
    -e "TZ=America/Mexico_City" \
    -e "GRAYLOG_WEB_ENDPOINT_URI=http://graylog.san.gadt.amxdigital.net" \
    -e "GRAYLOG_IS_MASTER=true" \
    -e "GRAYLOG_NODE_ID_FILE=/usr/share/graylog/data/config/node-id" \
    -e "GRAYLOG_PASSWORD_SECRET=1M3tsL1f3ZBEeKqO1K9W7XyLbWqiKI5yMJzGpEROwM1YGlJexSQJNgYfPs7DpaMXB3HtY6im3sViI73SpKVrNueBkmtMO40D" \
    -e "GRAYLOG_ROOT_USERNAME=amxga" \
    -e "GRAYLOG_ROOT_PASSWORD_SHA2=e9cee71ab932fde863338d08be4de9dfe39ea049bdafb342ce659ec5450b69ae" \
    -e "GRAYLOG_ROOT_TIMEZONE=America/Mexico_City" \
    -e "GRAYLOG_PLUGIN_DIR=/usr/share/graylog/plugin" \
    -e "GRAYLOG_REST_LISTEN_URI=http://0.0.0.0:9000/api/" \
    -e "GRAYLOG_WEB_LISTEN_URI=http://0.0.0.0:9000/" \
    -e "GRAYLOG_ELASTICSEARCH_HOSTS=http://10.23.142.134:9200, http://10.23.142.137:9200, http://10.23.142.133:9200" \
    -e "GRAYLOG_ELASTICSEARCH_COMPRESSION_ENABLED=true" \
    -e "GRAYLOG_ALLOW_LEADING_WILDCARD_SEARCHES=false" \
    -e "GRAYLOG_ALLOW_HIGHLIGHTING=false" \
    -e "GRAYLOG_OUTPUT_BATCH_SIZE=500" \
    -e "GRAYLOG_OUTPUT_FLUSH_INTERVAL=1" \
    -e "GRAYLOG_OUTPUT_FAULT_COUNT_THRESHOLD=5" \
    -e "GRAYLOG_OUTPUT_FAULT_PENALTY_SECONDS=30" \
    -e "GRAYLOG_PROCESSBUFFER_PROCESSORS=5" \
    -e "GRAYLOG_OUTPUTBUFFER_PROCESSORS=3" \
    -e "GRAYLOG_PROCESSOR_WAIT_STRATEGY=blocking" \
    -e "GRAYLOG_RING_SIZE=65536" \
    -e "GRAYLOG_INPUTBUFFER_RING_SIZE=65536" \
    -e "GRAYLOG_INPUTBUFFER_PROCESSORS=2" \
    -e "GRAYLOG_INPUTBUFFER_WAIT_STRATEGY=blocking" \
    -e "GRAYLOG_MESSAGE_JOURNAL_ENABLED=true" \
    -e "GRAYLOG_MESSAGE_JOURNAL_DIR=/usr/share/graylog/data/journal" \
    -e "GRAYLOG_LB_RECOGNITION_PERIOD_SECONDS=3" \
    -e "GRAYLOG_MONGODB_URI=mongodb://mongo/graylog" \
    -e "GRAYLOG_MONGODB_MAX_CONNECTIONS=100" \
    -e "GRAYLOG_MONGODB_THREADS_ALLOWED_TO_BLOCK_MULTIPLIER=5" \
    -e "GRAYLOG_CONTENT_PACKS_LOADER_ENABLED=true" \
    -e "GRAYLOG_CONTENT_PACKS_DIR=/usr/share/graylog/data/contentpacks" \
    -e "GRAYLOG_CONTENT_PACKS_AUTO_LOAD=grok-patterns.json" \
    -e "GRAYLOG_PROXIED_REQUESTS_THREAD_POOL_SIZE=32" \
    -e "ES_JAVA_OPTS=-Xms1024m -Xmx4096m" \
    -p 9100:9000 \
    -p 12201:12201 \
    -p 514:514 \
    -p 5555:5555 \
    -p 5556-5580:5556-5580 \
    -p 6666-6690:6666-6690/udp \
    -p 7777-7778:7777-7778/udp \
    -p 8888-8898:8888-8898 \
    --link $MONGO_CONTAINER:mongo \
    graylog/graylog:3.2
