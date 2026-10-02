# Forum DevOps - Bai thuc hanh Trien khai va Quan tri He thong Phan mem (De 15)

- Ho ten: Ha Yen Giang
- MSSV: DTC245200643
- Lop: CNTT K23D

## De tai

Website dien dan gom chu de, bai viet, binh luan va nguoi dung, chay hoan toan bang Docker Compose.

## Cong nghe

- Node.js (Express, EJS) - ung dung web
- MySQL 8 - co so du lieu
- phpMyAdmin - quan tri co so du lieu
- Nginx - reverse proxy
- Prometheus - giam sat
- Grafana - hien thi dashboard
- Loki - luu tru log
- Promtail - thu thap log
- Docker
- Docker Compose

## Cau truc he thong

He thong gom cac thanh phan:

- Forum Web
- MySQL Database
- phpMyAdmin
- Nginx
- Prometheus
- Grafana
- Loki
- Promtail

## Cach chay

1. Sao chep file cau hinh: `cp .env.example .env` roi sua mat khau.
2. Chay: `docker compose up -d --build`
3. Truy cap:
   - Dien dan: http://192.168.83.129:3000
   - phpMyAdmin: http://192.168.83.129:8081 
## Nginx
- Reverse proxy tới app Node.js, HTTPS chứng chỉ tự ký (TLS 1.2/1.3)
- Security headers: HSTS, X-Frame-Options, X-Content-Type-Options, CSP, Referrer-Policy, Permissions-Policy
- Ẩn phiên bản Nginx (server_tokens off), đóng cổng 3000 của app



## Giam sat (Prometheus + Grafana)
- Prometheus thu so lieu tu: cAdvisor (container), nginx-prometheus-exporter (web server), mysqld-exporter (database)
- Grafana: `http://IP-may:3001` (tai khoan admin, mat khau la `GRAFANA_ADMIN_PASSWORD` trong `.env`)
- Prometheus: `http://IP-may:9090`
- Phan giam sat nam trong file `docker-compose.monitoring.yml`, duoc ghep tu dong nho bien `COMPOSE_FILE` trong `.env`
- Mang: Prometheus, Grafana, cAdvisor o mang `default`; hai exporter noi them vao `forum-network` de doc so lieu tu Nginx va MySQL, nen Prometheus/Grafana khong truy cap truc tiep duoc MySQL
- Truoc khi chay lan dau: `cp .env.example .env` (sua mat khau manh), `bash nginx/gen-cert.sh`, `docker compose up -d mysql`, doi mysql healthy, `bash monitoring/setup-exporter.sh`, roi `docker compose up -d --build`
- Gioi han bo nho tung container, luu du lieu Prometheus toi da 3 ngay

## Log tap trung (Loki + Promtail)
- Promtail doc log cac container (qua docker.sock), day sang Loki; Grafana xem log qua data source Loki
- Phan log nam trong file `docker-compose.logging.yml`, duoc ghep nho bien `COMPOSE_FILE` trong `.env`
- Loki khong mo cong ra ngoai; log giu 72 gio
- Truy van LogQL mau (Grafana > Explore > chon Loki):
  - `{service="nginx"}`: log truy cap Nginx
  - `{service="nginx"} |~ `" [45][0-9][0-9] ``: cac request loi 4xx/5xx
  - `sum by (service) (rate({container=~"forum-.*"}[1m]))`: toc do sinh log theo dich vu
