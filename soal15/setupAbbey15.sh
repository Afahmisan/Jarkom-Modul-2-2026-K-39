#!/bin/bash
set -e

echo "[1/4] Memastikan Nginx terpasang..."
apt-get update -y
apt-get install -y nginx

echo "[2/4] Menyiapkan berkas statis & berkas uji pembuktian di /var/www/orion..."
mkdir -p /var/www/orion

# 1. Berkas HTML statis utama
cat << 'EOF' > /var/www/orion/index.html
<!doctype html>
<html>
<head><title>Orion Area</title></head>
<body>
    <h1>Orion Static Route on Abbey (No PHP)</h1>
    <p>Layanan statis mandiri lokal Abbey aktif.</p>
</body>
</html>
EOF

# 2. Berkas PHP uji (Membuktikan bahwa PHP TIDAK dieksekusi)
cat << 'EOF' > /var/www/orion/tes.php
<?php echo "KODE_PHP_INI_TIDAK_DIEKSEKUSI_MURNI_STATIS"; ?>
EOF

chown -R www-data:www-data /var/www/orion
chmod -R 755 /var/www/orion

echo "[3/4] Menulis konfigurasi Nginx (Isolasi /orion + Redirect Kanonik 302)..."
cat << 'EOF' > /etc/nginx/sites-available/abbey-proxy
upstream core_cluster {
    server 10.83.1.6:80;
    server 10.83.1.7:80;
}

# REDIRECTOR: Akses IP Abbey & domain abbey.k-39.com -> 302 ke static.k-39.com (Soal 13)
server {
    listen 80 default_server;
    server_name abbey.k-39.com _;
    return 302 http://static.k-39.com$request_uri;
}

# SERVER KANONIK: static.k-39.com
server {
    listen 80;
    server_name static.k-39.com;

    # SOAL 15: Jalur /orion BERDIRI SENDIRI di lokal Abbey (Bebas dari cluster Core)
    location /orion {
        root /var/www;
        index index.html;
    }

    # Sisanya diteruskan ke cluster Core (Oblada & Molly)
    location / {
        proxy_pass http://core_cluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

echo "[4/4] Mengaktifkan site & restart Nginx bersih..."
rm -f /etc/nginx/sites-enabled/*
ln -sf /etc/nginx/sites-available/abbey-proxy /etc/nginx/sites-enabled/abbey-proxy

nginx -t
killall -9 nginx 2>/dev/null || true
service nginx start

# Persistensi DebiNet
grep -qxF 'service nginx start' /root/.bashrc || echo 'service nginx start' >> /root/.bashrc

echo "Abbey Soal 15 Siap Digunakan!"