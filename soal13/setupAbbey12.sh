#!/bin/bash
set -e

mkdir -p /var/www/orion
echo "<h1>Orion Static Route on Abbey (No PHP)</h1>" > /var/www/orion/index.html
chown -R www-data:www-data /var/www/orion
chmod -R 755 /var/www/orion

cat << 'EOF' > /etc/nginx/sites-available/abbey-proxy
upstream core_cluster {
    server 10.83.1.6:80;
    server 10.83.1.7:80;
}

# 1. Redirect 302 jika diakses via IP atau domain abbey.k-39.com
server {
    listen 80 default_server;
    server_name abbey.k-39.com _;
    return 302 http://static.k-39.com$request_uri;
}

# 2. Host Kanonik Utama
server {
    listen 80;
    server_name static.k-39.com;

    location /orion/ {
        alias /var/www/orion/;
        index index.html;
    }

    location / {
        proxy_pass http://core_cluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Bersihkan dan pasang satu symlink saja
rm -f /etc/nginx/sites-enabled/*
ln -sf /etc/nginx/sites-available/abbey-proxy /etc/nginx/sites-enabled/abbey-proxy

nginx -t
service nginx restart

grep -qxF 'service nginx start' /root/.bashrc || echo 'service nginx start' >> /root/.bashrc
echo "Abbey Soal 13 aktif!"