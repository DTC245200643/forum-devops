#!/bin/bash
# Kiem tra hien trang bao mat (chi doc, khong in mat khau)
cd "$(dirname "$0")/.."
echo "=== A. User chay trong container ==="
for c in forum-web forum-mysql forum-nginx forum-phpmyadmin; do printf "%-18s " "$c"; docker exec $c id 2>&1 | head -1; done
echo
echo "=== B. Han che cua container forum-web ==="
docker inspect -f 'read_only={{.HostConfig.ReadonlyRootfs}} cap_drop={{.HostConfig.CapDrop}} security_opt={{.HostConfig.SecurityOpt}}' forum-web
echo
echo "=== C. Mang cua tung container ==="
for c in forum-web forum-mysql forum-nginx forum-phpmyadmin forum-mysqld-exporter forum-nginx-exporter; do printf "%-24s " "$c"; docker inspect -f '{{range $k,$v := .NetworkSettings.Networks}}{{$k}} {{end}}' $c; done
echo "Mang va thuoc tinh internal (internal=true la khong ra Internet):"
docker network ls --format '{{.Name}}' | grep forum-devops | while read n; do printf "  %-32s internal=" "$n"; docker network inspect -f '{{.Internal}}' "$n"; done
echo
echo "=== D. Cong mo ra ngoai ==="
docker compose ps --format 'table {{.Name}}\t{{.Ports}}'
echo
echo "=== E. Do dai mat khau trong .env (khong lo gia tri) ==="
awk -F= 'NF>1 && $1 ~ /PASS|SECRET/ {print "  "$1" -> "length($2)" ky tu"}' .env
echo
echo "=== F. Quyen database ==="
ROOTPW=$(docker compose exec -T mysql printenv MYSQL_ROOT_PASSWORD | tr -d '\r\n')
APPUSER=$(docker compose exec -T mysql printenv MYSQL_USER | tr -d '\r\n')
docker compose exec -T -e MYSQL_PWD="$ROOTPW" mysql mysql -uroot -e "SELECT user,host FROM mysql.user WHERE user NOT LIKE 'mysql.%'; SHOW GRANTS FOR '$APPUSER'@'%';" 2>&1 | grep -v "Using a password"
