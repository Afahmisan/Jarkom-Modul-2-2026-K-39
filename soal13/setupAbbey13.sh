#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y nginx

# 1. Siapkan folder dan berkas statis mandiri /orion
mkdir -p /var/www/orion
echo "<h1>Orion Static Route on Abbey (No PHP)</h1>" > /var/www/orion/index.html
chown -R www-data:www-data /var/www/orion
chmod -R 755 /var/www/orion

# 2. Tulis VirtualHost Abbey (Redirect 302 + Kanonik static.k-39.com)
cat << 'EOF' > /etc/nginx/sites-available/abbey-proxy
upstream core_cluster {
    server 10.83.1.6:80;
    server 10.83.1.7:80;
}

# --- 1. REDIRECTOR: Akses IP Abbey & domain abbey.k-39.com -> 302 ke static.k-39.com ---
server {
    listen 80 default_server;
    server_name abbey.k-39.com _;
    return 302 http://static.k-39.com$request_uri;
}

# --- 2. SERVER BLOCK KANONIK: static.k-39.com ---
server {
    listen 80;
    server_name static.k-39.com;

    # Jalur mandiri lokal /orion
    location /orion/ {
        alias /var/www/orion/;
        index index.html;
    }

    # Load Balancer ke Area Core (Oblada & Molly)
    location / {
        proxy_pass http://core_cluster;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# 3. Bersihkan symlink lama agar tidak duplicate upstream
rm -f /etc/nginx/sites-enabled/*
ln -sf /etc/nginx/sites-available/abbey-proxy /etc/nginx/sites-enabled/abbey-proxy

# 4. Tes konfigurasi dan restart Nginx
nginx -t
service nginx restart

# Persistensi saat reboot di DebiNet
grep -qxF 'service nginx start' /root/.bashrc || echo 'service nginx start' >> /root/.bashrc

echo "Setup Abbey Soal 13 Selesai!"