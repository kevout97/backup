#!/bin/bash
################################################
#                                              #
#               Cassandra Runit                #
#                                              #
################################################

#firewall-cmd --permanent --add-port=7000/tcp
#firewall-cmd --permanent --add-port=9160/tcp
#firewall-cmd --permanent --add-port=9042/tcp
#firewall-cmd --reload

CASSANDRA_CLUSTER_NAME='jitsi-cassandra'
CASSANDRA_LISTEN_ADDRESS="172.26.90.154" # Ip del servidor
CASSANDRA_CLUSTER_SEEDS="172.26.90.154,172.26.90.155,172.26.90.156" # Ip de los nodos que conformarán el cluster
CASSANDRA_DC="jitsi-cassandra-dc" # Nombre dle datacenter de este nodo
CASSANDRA_RACK="jitsi-cassandra-rc" # Nombre del rack de este nodo
CASSANDRA_CONTAINER="jvpdcass01-1.iris.io.service"
CASSANDRA_ADMIN_PASSWORD="C4g2MV6VmQxz"
CASSANDRA_ADMIN_USER="admin"

mkdir -p /var/containers/$CASSANDRA_CONTAINER/{var/lib/cassandra,etc/cassandra/conf/}

cat<<-EOF > /var/containers/$CASSANDRA_CONTAINER/etc/cassandra/conf/cassandra.yaml
cluster_name: $CASSANDRA_CLUSTER_NAME
broadcast_rpc_address: $CASSANDRA_LISTEN_ADDRESS
broadcast_address: $CASSANDRA_LISTEN_ADDRESS
data_file_directories:
  - /var/lib/cassandra/data
commitlog_directory: /var/lib/cassandra/commitlog
hints_directory: /var/lib/cassandra/hints
commit_failure_policy: stop
disk_optimization_strategy: ssd
endpoint_snitch: GossipingPropertyFileSnitch
rpc_address: 0.0.0.0
seed_provider:
    - class_name: org.apache.cassandra.locator.SimpleSeedProvider
      parameters:
          - seeds: $CASSANDRA_CLUSTER_SEEDS
enable_user_defined_functions: false
enable_scripted_user_defined_functions: false
compaction_throughput_mb_per_sec: 16
compaction_large_partition_warning_threshold_mb: 100
concurrent_reads: 32
concurrent_writes: 96
concurrent_counter_writes: 32
concurrent_materialized_view_writes: 32
incremental_backups: false
snapshot_before_compaction: false
commitlog_sync: periodic
commitlog_segment_size_in_mb: 32
auto_bootstrap: false
num_tokens: 256
hinted_handoff_enabled: true
max_hint_window_in_ms: 3600000
hinted_handoff_throttle_in_kb: 1024
max_hints_delivery_threads: 3
disk_failure_policy: stop
authenticator: org.apache.cassandra.auth.PasswordAuthenticator
authorizer: org.apache.cassandra.auth.CassandraAuthorizer
role_manager: CassandraRoleManager
storage_port: 7000
ssl_storage_port: 7001
native_transport_port: 9042
rpc_port: 9160
start_rpc: true
rpc_keepalive: true
rpc_server_type: sync
transparent_data_encryption_options:
    enabled: false
    chunk_length_kb: 64
    cipher: AES/CBC/PKCS5Padding
    key_alias: testing:1
    key_provider: 
      - class_name: org.apache.cassandra.security.JKSKeyProvider
        parameters: 
          - keystore: conf/.keystore
            keystore_password: cassandra
            store_type: JCEKS
            key_password: cassandra
server_encryption_options:
    internode_encryption: none
    keystore: conf/.keystore
    keystore_password: cassandra
    truststore: conf/.truststore
    truststore_password: cassandra
client_encryption_options:
    enabled: false
    optional: false
    keystore: conf/.keystore
    keystore_password: cassandra
concurrent_compactors: 2
row_cache_size_in_mb: 0
row_cache_save_period: 0
auto_snapshot: true
truncate_request_timeout_in_ms: 600000
partitioner: org.apache.cassandra.dht.Murmur3Partitioner
key_cache_size_in_mb:
key_cache_save_period: 14400
hints_flush_period_in_ms: 10000
max_hints_file_size_in_mb: 128
batchlog_replay_throttle_in_kb: 1024
roles_validity_in_ms: 2000
permissions_validity_in_ms: 2000
cdc_enabled: false
prepared_statements_cache_size_mb:
thrift_prepared_statements_cache_size_mb:
counter_cache_size_in_mb:
counter_cache_save_period: 7200
commitlog_sync_period_in_ms: 10000
memtable_allocation_type: offheap_objects
memtable_flush_writers: 1
index_summary_capacity_in_mb:
index_summary_resize_interval_in_minutes: 60
trickle_fsync: false
trickle_fsync_interval_in_kb: 10240
start_native_transport: true
thrift_framed_transport_size_in_mb: 15
column_index_size_in_kb: 64
column_index_cache_size_in_kb: 2
sstable_preemptive_open_interval_in_mb: 50
read_request_timeout_in_ms: 5000
range_request_timeout_in_ms: 10000
write_request_timeout_in_ms: 2000
counter_write_request_timeout_in_ms: 5000
cas_contention_timeout_in_ms: 1000
request_timeout_in_ms: 10000
slow_query_log_timeout_in_ms: 500
cross_node_timeout: false
dynamic_snitch_update_interval_in_ms: 100 
dynamic_snitch_reset_interval_in_ms: 600000
dynamic_snitch_badness_threshold: 0.1
request_scheduler: org.apache.cassandra.scheduler.NoScheduler
internode_compression: dc
inter_dc_tcp_nodelay: false
tracetype_query_ttl: 86400
tracetype_repair_ttl: 604800
windows_timer_interval: 1
tombstone_warn_threshold: 1000
tombstone_failure_threshold: 100000
batch_size_warn_threshold_in_kb: 5
batch_size_fail_threshold_in_kb: 50
unlogged_batch_across_partitions_warn_threshold: 10
gc_warn_threshold_in_ms: 1000
back_pressure_enabled: false
enable_materialized_views: true
enable_sasi_indexes: true
EOF

sysctl -w vm.max_map_count=1048575
echo never | tee /sys/kernel/mm/transparent_hugepage/defrag

docker run -itd --name $CASSANDRA_CONTAINER \
    --memory-swappiness=0 \
    --restart unless-stopped \
    --ulimit memlock=-1:-1 \
    -p 7000:7000 \
    -p 7001:7001 \
    -p 9160:9160 \
    -p 9042:9042 \
    -v /var/containers/$CASSANDRA_CONTAINER/var/lib/cassandra:/var/lib/cassandra:z \
    -v /var/containers/$CASSANDRA_CONTAINER/etc/cassandra/conf/:/etc/cassandra/conf/:z \
    -v /etc/localtime:/etc/localtime:ro \
    -e "TZ=America/Mexico_City" \
    -e CASSANDRA_DC=$CASSANDRA_DC \
    -e CASSANDRA_RACK=$CASSANDRA_RACK \
    -e CASSANDRA_ADMIN_USER=$CASSANDRA_ADMIN_USER \
    -e CASSANDRA_ADMIN_PASSWORD=$CASSANDRA_ADMIN_PASSWORD \
    -e MAX_HEAP_SIZE="24576M" \
    -e HEAP_NEWSIZE="6144M" \
    -e LOCAL_JMX="no" \
    -e JVM_OPTS="-XX:NewSize=6144M -XX:MaxNewSize=6144M" \
    cassandra:3.11.6 -Dcassandra.config=file:///etc/cassandra/conf/cassandra.yaml

sleep 65
docker exec -it $CASSANDRA_CONTAINER bash -c "echo \"$CASSANDRA_ADMIN_USER $CASSANDRA_ADMIN_PASSWORD\" >> /etc/cassandra/jmxremote.password"
docker exec -it $CASSANDRA_CONTAINER bash -c 'apt-get update && apt-get install python-tz -y'
docker exec -it $CASSANDRA_CONTAINER bash -c "echo \"create role $CASSANDRA_ADMIN_USER with password = '$CASSANDRA_ADMIN_PASSWORD' AND SUPERUSER = true AND LOGIN = true;\" | cqlsh $(cat /etc/hostname) -u cassandra -p cassandra"
docker exec -it $CASSANDRA_CONTAINER bash -c "echo \"drop role cassandra;\" | cqlsh $(cat /etc/hostname) -u $CASSANDRA_ADMIN_USER -p $CASSANDRA_ADMIN_PASSWORD"
# docker exec -it $CASSANDRA_CONTAINER cqlsh -u $CASSANDRA_ADMIN_USER -p $CASSANDRA_ADMIN_PASSWORD
# docker exec -it $CASSANDRA_CONTAINER nodetool -u $CASSANDRA_ADMIN_USER -pw $CASSANDRA_ADMIN_PASSWORD status