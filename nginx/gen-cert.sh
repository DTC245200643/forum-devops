#!/bin/bash
# Tao chung chi HTTPS tu ky, chay tu thu muc goc cua project
mkdir -p nginx/certs
openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
  -keyout nginx/certs/server.key \
  -out nginx/certs/server.crt \
  -subj "/C=VN/ST=Thai Nguyen/O=Forum DevOps/CN=forum.local" \
  -addext "subjectAltName=DNS:localhost,DNS:forum.local,IP:127.0.0.1,IP:192.168.83.129"
echo "Da tao xong chung chi trong nginx/certs/"
