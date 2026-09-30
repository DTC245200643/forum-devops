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


