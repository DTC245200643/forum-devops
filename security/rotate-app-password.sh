#!/bin/bash
# Doi mat khau user ung dung sang chuoi ngau nhien 32 ky tu, cap nhat .env (khong in mat khau)
set -e
cd "$(dirname "$0")/.."
ROOTPW=$(docker compose exec -T mysql printenv MYSQL_ROOT_PASSWORD | tr -d '\r\n')
APPUSER=$(docker compose exec -T mysql printenv MYSQL_USER | tr -d '\r\n')
if [ -z "$ROOTPW" ] || [ -z "$APPUSER" ]; then echo "Khong doc duoc thong tin tu container mysql"; exit 1; fi
NEWPW=$(openssl rand -hex 16)
docker compose exec -T -e MYSQL_PWD="$ROOTPW" mysql mysql -uroot -e "ALTER USER '${APPUSER}'@'%' IDENTIFIED BY '${NEWPW}'; FLUSH PRIVILEGES;" 2>/dev/null || { echo "Loi khi doi mat khau trong MySQL, .env chua bi sua"; exit 1; }
sed -i "s|^MYSQL_PASSWORD=.*|MYSQL_PASSWORD=${NEWPW}|" .env
echo "Xong: MYSQL_PASSWORD moi dai ${#NEWPW} ky tu (da cap nhat .env)"
