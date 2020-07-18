#!/bin/bash

if [[ -f /etc/mysql/deny-container-exec || -f /UD01/mysql/data/deny-container-exec || -f /var/log/mysql/deny-container-exec ]] && [ -z "$ephemeral" ]; then

    echo "Mount /etc/mysql/ /UD01/mysql/data/ and /var/log/mysql/"
    echo "volumes or set ephemeral env (e.g. -e 'ephemeral=1') with any value"
    exit 1

fi
if [ -n "$ephemeral" ]; then

    rm -f /etc/mysql/deny-container-exec /UD01/mysql/data/deny-container-exec
fi
if [ -z "$(ls -A /UD01/mysql/data)" ]; then
    if [ -z "${mysql_root_password}" ]; then
        echo >&2 'error: database is uninitialized and mysql_root_password not set'
        echo >&2 '  Did you forget to add -e "mysql_root_password=..." ?'
        exit 1
    fi
    if [ ! -f /etc/mysql/my.cnf ]; then
        echo "H4sICC5XKFsAA215LmNuZgCtV9tuGzcQfedXENBrLGnlS1IX++DagmLEsQE7fQoCgrukJFZcckNybSv/1J/ol3WG3LVkaeW0aA1jraUOZ4YzZ87QX6u1/66/ETKglzfX09svdEBq6wJtf3J6fDw+I96WKxm6pdEjd6NQ1aO4OT2HCCHka3wR0eBseju9v7gBi166R+mYEnH7+/GYHvgZ0GtTOllJE7ijpTVUamqaSjpLhaRoRwnrpCeCBy6U6yL6/WqcteHgN69MTg0N0lXKWJ+MLBqnBBfvqJOlrZQ0ghta8qpQ4FQDquZhidg5b3QgBfdyy1Xj3UjbkrcH/19d/dM8w2IX0RbuUE7/a1Q9hCDyudaqVIG1IM/m1rGgKukDh1BymhG/UjUzvJIMKmb1oySk1s1CmSNtuXgVZB6WTnLBamvxiETbJyBMCZlngRdaRjMecNm2iSMuNmbyR67hVEGymnv/ZJ1AQyRS++Ly4/SBXtxe0Zvrz9dfHoCTpOLPDBhmZBmUNX4vb/lkHIk6uGwTA/ato7zjo/S1dFzYaIhrjBji55sCvhjKZtvOmHTOOr+LGY9JOqmtpYGTl0vJlIFkmlL6DnS2h9mLOhtPTpAfbd68+rGHAdSHz6TNePLUA8t/AeaXK6btoodVrZkxmevGL2PhD2DG5A+rDCua+RxK2hdPPjk9+wTcd+HnqHQqIJ0yCuu2m4U8O4FMFspA2MzZJyYfQUwY5n/LaP7hEzJYOYnH80zw9R4B8vcEbYApFlzjA5s3pkwuIXEBSgjcahGHEtQ1J8DaJk6R+fR2BG+Rode3t3dXvxFljBUFmys4IpArlbDPatZBUexaPLRsH1QViMnOT7PJ51/TyyS+nPMmWPkcoPs7a8A2aGTw7JWH9fCG48gdZVli0X73RLK22CenoCvfAOcnHbStP8pAP3Xzkxn+GUwhVmhBqjn0pVMxURX3VFWoVtwE+Q70C9oEBA9+AeZ4RYXytTUKwTLOlm6iDA+lgHlQs5jeRWrD2KktGKsfk9/fZcjZWfrQ7QCulivfVCAYCwtpWVa7O0pXHk9emMCBd37ZBGGfekmWv8SS+hAj4gEIi3JTVWqrhJvaRdIebrQkDy12QxJQo3Y0v8aevRQPBK5snJOmXIMgoBDuqtzpeJM8qwUrYJCu/AH1wExv0Kh4mOseqiX08QYcJOjfW60BXQESmZ2/boNzUInz7HTWmQHGlhwUXYV12kUznAgDfCoYks4WwLs1LWSA+UrncTp4ZRZAL1+DEfiIlFsNeyyiJIHFk2gRRs1ff9Jg4+u/NI0D7uZuhjMNCnsUp8uBHKVD7CjS9P7+7j59TqNpCN8RD/OMfW+kWx8eAMCo17CY7p97xE3RibZm0e4+OECABVFlEaakZ8YG1mAmgI9CPr/wAYJZSAMTWb81saBh8Dn4yAulFV4yuaZxzGruUDF83Ui8+fhlhxjSB0lhFVSk8bCh5o5jgWAsw00JbwGlmqvS+m3//ZlA/zu5aPfEdAx4I+BG9db2fQNxT3pGI0CHdAnH4d3U3yjdnLVsuBEWRA+v1nMF10A8UwP6aekal6ELFhx1EQYTrg7JIJk5gutm8pze2wEmuNLrtDLacjoigwaUNW+HXFwjg3S5beNXRc9/D38DrL9DoY4MAAA=" \
| base64 -w0 -d | gunzip  > /etc/mysql/my.cnf
    fi
    echo "Initializing mysqld data dir"
    mkdir -p /UD01/mysql/data
    mkdir -p /var/log/mysql/{ERROR/,binlogs/}
    mkdir -p /var/tmp/mysql/
    chown mysql:mysql /UD01/mysql/data
    chown mysql:mysql /var/log/mysql/
    chown mysql:mysql /var/log/mysql/ERROR/
    chown mysql:mysql /var/log/mysql/binlogs/
    chown mysql:mysql /var/tmp/mysql/
    /usr/sbin/mysqld --defaults-file=/etc/mysql/my.cnf --initialize --datadir=/UD01/mysql/data --user=mysql
    RC=$?
    if [ $RC -gt 0 ]; then
        echo "Error on mysql initialization"
        exit 2
    fi
    echo "Preparing root password script."
    # 2Do: proper SQL escaping on dat root password D:
    cat > /tmp/mysql-first-time.sql <<-EOSQL
            FLUSH PRIVILEGES ;
            DROP DATABASE IF EXISTS test ;
            ALTER USER 'root'@'localhost' IDENTIFIED BY '${mysql_root_password}';
            FLUSH PRIVILEGES ;
            SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${mysql_root_password}');
            FLUSH PRIVILEGES ;
EOSQL

    echo "Setup mysqld root password"
    /usr/sbin/mysqld --defaults-file=/etc/mysql/my.cnf --init-file=/tmp/mysql-first-time.sql --user=mysql &
    sleep 120
    exit_sucess=0
    for i in {1..5}; do
        sleep 1
        /usr/bin/mysqladmin --socket=/var/tmp/mysql/mysql.sock -uroot -p${mysql_root_password} shutdown
        exit_sucess=$?
        if [ $exit_sucess -eq 0 ]; then
            echo "root password changed"
            break
        fi
    done

fi
echo "init exec mysqld"
exec /usr/sbin/mysqld --defaults-file=/etc/mysql/my.cnf --datadir=/UD01/mysql/data --user=mysql
