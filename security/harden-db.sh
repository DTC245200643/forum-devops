#!/bin/bash
# Han che quyen database: user ung dung chi SELECT/INSERT/UPDATE/DELETE tren database cua ung dung; khoa root dang nhap tu xa
set -e
cd "$(dirname "$0")/.."
ROOTPW=$(docker compose exec -T mysql printenv MYSQL_ROOT_PASSWORD | tr -d '\r\n')
APPUSER=$(docker compose exec -T mysql printenv MYSQL_USER | tr -d '\r\n')
DBNAME=$(docker compose exec -T mysql printenv MYSQL_DATABASE | tr -d '\r\n')
if [ -z "$ROOTPW" ] || [ -z "$APPUSER" ] || [ -z "$DBNAME" ]; then echo "Khong doc duoc thong tin tu container mysql"; exit 1; fi
docker compose exec -T -e MYSQL_PWD="$ROOTPW" mysql mysql -uroot -e "
REVOKE ALL PRIVILEGES, GRANT OPTION FROM '${APPUSER}'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON \`${DBNAME}\`.* TO '${APPUSER}'@'%';
DROP USER IF EXISTS 'root'@'%';
FLUSH PRIVILEGES;
SHOW GRANTS FOR '${APPUSER}'@'%';
SELECT user,host FROM mysql.user WHERE user NOT LIKE 'mysql.%';" 2>/dev/null || { echo "Loi khi chay lenh SQL"; exit 1; }
echo "Xong: da han che quyen database"
