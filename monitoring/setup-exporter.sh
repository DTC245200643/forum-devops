#!/bin/bash
# Tao user MySQL quyen han che cho exporter va file cau hinh ket noi
# Chay tu thu muc goc cua project, khi container mysql dang chay
set -e
set -a; . ./.env; set +a
ROOTPW=$(docker compose exec -T mysql printenv MYSQL_ROOT_PASSWORD | tr -d '\r\n')
if [ -z "$ROOTPW" ]; then echo "Khong lay duoc mat khau root tu container mysql"; exit 1; fi
docker compose exec -T -e MYSQL_PWD="$ROOTPW" mysql mysql -uroot -e "CREATE USER IF NOT EXISTS 'exporter'@'%' IDENTIFIED BY '${EXPORTER_PASSWORD}' WITH MAX_USER_CONNECTIONS 3; ALTER USER 'exporter'@'%' IDENTIFIED BY '${EXPORTER_PASSWORD}'; GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'%'; FLUSH PRIVILEGES;"
cat > monitoring/mysqld-exporter.cnf << CNF
[client]
user=exporter
password=${EXPORTER_PASSWORD}
host=mysql
port=3306
CNF
chmod 644 monitoring/mysqld-exporter.cnf
echo "Xong: da tao user exporter va file monitoring/mysqld-exporter.cnf"
