#!/bin/bash

set -exo pipefail

if [ -z "$(ls -A /var/lib/mongo)" ] && [ -z "$(ls -A /data/db)" ]; then
    if [ -z "${mongo_root_password}" ]; then
        echo >&2 '[AMX] Error: database is uninitialized and mongo_root_password not set'
        echo >&2 '[AMX] Did you forget to add -e "mongo_root_password=..." ?'
        exit 1
    fi
    echo "[AMX] Preparing root password script."
    cat > /tmp/create-root-user.js <<-EOMONGO
            use admin
            db.createUser(
                {
                    user: "root",
                    pwd: "${mongo_root_password}",
                    roles: [ { role: "userAdminAnyDatabase", db: "admin" }, "readWriteAnyDatabase", "root", "backup", "clusterManager" ]
                }
            )
EOMONGO
    echo "[AMX] Setup mongod root password"
    /usr/bin/mongod --fork --logpath /var/log/mongodb/mongod.log
    /usr/bin/mongo < /tmp/create-root-user.js
    RC=$?
    if [ $RC -gt 0 ]; then
        echo "[AMX] Error on mongo initialization"
        exit 2
    else
        echo "[AMX] Root password and user has be create"
        echo "[AMX] Mongo restart to update changes"
        /usr/bin/mongod --shutdown
    fi
fi
echo "[AMX] Init exec mongod"
exec /usr/bin/mongod --bind_ip 0.0.0.0 --auth --logpath /var/log/mongodb/mongod.log