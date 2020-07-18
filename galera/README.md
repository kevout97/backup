# Galera

## Prerequisitos

* Un minimo de 3 Nodos

## Desarrollo

### Despliegue de Cluster Galera

Para el despliegue del nodo Master hacemos uso del siguiente comando:

```bash

CONTAINER=galera_master

mkdir -p /var/containers/${CONTAINER}/ 
chown 1017:1017 -R /var/containers/${CONTAINER}/ 
IS_MASTER=1
hostname=$(hostname)

docker run -itd --name=${CONTAINER} \
        -p 3307:3307/tcp -p 4567:4567/tcp -p 4567:4567/udp -p 4568:4568/tcp -p 4444:4444/tcp \
        --net=host \
        --hostname=${CONTAINER}.service \
        --ulimit nofile=40240:40240 \
        --ulimit nproc=35000:40960 \
        -e 'DEBUG=1' \
        -e 'LANG=en_US.UTF-8' \
        --restart unless-stopped \
        -e "MYSQL_ROOT_PASSWORD=changeThisPassword0N#W" \
        -v /var/backups/mysqldailybackup/:/var/backups/mysqldailybackup/:z \
        -v /var/containers/${CONTAINER}/var/log/mysql/:/var/log/mysql/:Z \
        -v /var/containers/${CONTAINER}/var/log/mysql/Binlogs:/var/log/mysql/Binlogs:Z \
        -v /var/containers/${CONTAINER}/var/log/mysql/Bitacora:/var/log/mysql/Bitacora:Z \
        -v /var/containers/${CONTAINER}/var/log/mysql/Audit:/var/log/mysql/Audit:Z \
        -v /var/containers/${CONTAINER}/UD01/mysql/data/:/UD01/mysql/data/:Z \
        -v /var/containers/${CONTAINER}/var/backups/ejecucionesscript/:/var/backups/ejecucionesscript/:Z \
        -v /var/containers/${CONTAINER}/var/tmp/mysql/:/var/tmp/mysql/:Z \
        -v /etc/localtime:/etc/localtime:ro \
        -e "IS_MASTER=${IS_MASTER}" \
        -e "galera_var_wsrep_node_name=$hostname" \
        -e "galera_var_wsrep_node_address=\"10.10.10.10\"" \
        -e "galera_var_wsrep_cluster_address=\"gcomm://10.10.10.10,10.10.10.11,10.10.10.12\"" \
        -e "galera_var_back_log =80" \
        -e "galera_var_binlog_format=ROW" \
        -e "galera_var_binlog_row_event_max_size =8K" \
        -e "galera_var_character_set_client_handshake = FALSE" \
        -e "galera_var_character_set_server = utf8mb4" \
        -e "galera_var_collation_server = utf8mb4_unicode_ci" \
        -e "galera_var_datadir=/UD01/mysql/data" \
        -e "galera_var_default_storage_engine=innodb" \
        -e "galera_var_expire_logs_days =4" \
        -e "galera_var_flush_time =0" \
        -e "galera_var_general_log =1" \
        -e "galera_var_general_log_file =/var/log/mysql/general.log" \
        -e "galera_var_innodb_autoextend_increment =64" \
        -e "galera_var_innodb_autoinc_lock_mode =2" \
        -e "galera_var_innodb_buffer_pool_instances = 16" \
        -e "galera_var_innodb_buffer_pool_size=1G" \
        -e "galera_var_innodb_checksum_algorithm =crc32" \
        -e "galera_var_innodb_concurrency_tickets =5000" \
        -e "galera_var_innodb_fast_shutdown =0" \
        -e "galera_var_innodb_file_per_table =1" \
        -e "galera_var_innodb_flush_log_at_trx_commit =0" \
        -e "galera_var_innodb_log_buffer_size =8M" \
        -e "galera_var_innodb_log_file_size =2G" \
        -e "galera_var_innodb_old_blocks_time =1000" \
        -e "galera_var_innodb_open_files =300" \
        -e "galera_var_innodb_page_cleaners = 8" \
        -e "galera_var_innodb_read_io_threads =16" \
        -e "galera_var_innodb_stats_persistent =1" \
        -e "galera_var_innodb_stats_persistent_sample_pages =100" \
        -e "galera_var_innodb_temp_data_file_path =ibtmp1:12M:autoextend:max:15G" \
        -e "galera_var_innodb_write_io_threads =4" \
        -e "galera_var_join_buffer_size =256K" \
        -e "galera_var_log_bin_trust_function_creators" \
        -e "galera_var_log_queries_not_using_indexes=0" \
        -e "galera_var_log_timestamps='SYSTEM'" \
        -e "galera_var_long_query_time=5" \
        -e "galera_var_lower_case_table_names=1" \
        -e "galera_var_max_allowed_packet=1G" \
        -e "galera_var_max_connect_errors=100" \
        -e "galera_var_max_connections=1024" \
        -e "galera_var_port = 3307" \
        -e "galera_var_query_cache_size = 0" \
        -e "galera_var_query_cache_type = 0" \
        -e "galera_var_slow_query_log =1" \
        -e "galera_var_slow_query_log_file = /var/log/mysql/slow.log" \
        -e "galera_var_sort_buffer_size =128K" \
        -e "galera_var_sync_binlog =1" \
        -e "galera_var_table_definition_cache =1400" \
        -e "galera_var_table_open_cache =2064" \
        -e "galera_var_table_open_cache_instances =16" \
        -e "galera_var_thread_cache_size =9" \
        -e "galera_var_tmp_table_size =8M" \
        -e "galera_var_user=mysql" \
        -e "galera_var_wsrep_cluster_name=\"amxclust\"" \
        -e "galera_var_wsrep_provider_options=\"gcache.size=300M; gcache.page_size=300M\"" \
        -e "galera_var_wsrep_provider=/usr/lib64/galera-3/libgalera_smm.so" \
        -e "galera_var_wsrep_sst_method=rsync" \
            docker-source-registry.plataforma-claro.com/atomic-rhel7-galera-3
```

Con la variable **IS_MASTER** se determina si el nodo que se desplegara sera del tipo master.
* **1**: Nodo Master
* **0**: Nodo Slave

Con la variable **galera_var_wsrep_cluster_address** se indican todos los nodos que conformarán el cluster de Galera, la sitanxis es la siguiente:
  ```conf
  gcomm://ip_nodo1,ip_nodo2,..
  ```

Con la variable **galera_var_wsrep_node_address** se señala la Ip con la que se anunciará dicho nodo del cluster.