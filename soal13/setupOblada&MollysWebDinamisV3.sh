#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

echo "[1/4] Memasang Nginx & PHP-FPM..."
apt-get update -y
apt-get install -y nginx php-fpm

PHP_V=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')

echo "[2/4] Menyiapkan konten PHP dinamis dan Clean URL..."
mkdir -p /var/www/core

cat > /var/www/core/index.php <<'PHP'
<!doctype html>
<html>
<head><title>Core Area - Beranda</title></head>
<body>
    <h1>Selamat Datang di Core Backend (Dinamis - PHP)</h1>
    <p>Server: <?php echo gethostname(); ?></p>
    <p>Waktu Server: <?php echo date('Y-m-d H:i:s'); ?></p>
    <hr>
    <a href="/profil">Lihat Halaman Profil</a>
</body>
</html>
PHP

cat > /var/www/core/profil.php <<'PHP'
<!doctype html>
<html>
<head><title>Core Area - Profil</title></head>
<body>
    <h1>Halaman Profil Server Core</h1>
    <p>Status: Layanan dinamis PHP-FPM berhasil dieksekusi dengan Clean URL.</p>
    <hr>
    <a href="/">Kembali ke Beranda</a>
</body>
</html>
PHP

chown -R www-data:www-data /var/www/core
chmod -R 755 /var/www/core

echo "[3/4] Mengonfigurasi Nginx Real-IP & VirtualHost..."
cat << 'EOF' > /etc/nginx/conf.d/real_ip.conf
set_real_ip_from 10.83.2.2;
set_real_ip_from 10.83.3.2;
real_ip_header X-Real-IP;
real_ip_recursive on;
EOF

cat > /etc/nginx/sites-available/core.conf <<NGINX
server {
    listen 80;
    server_name core.k-39.com oblada.k-39.com molly.k-39.com abbey.k-39.com static.k-39.com k-39.com;

    root /var/www/core;
    index index.php index.html;

    rewrite ^/profil/?$ /profil.php last;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php${PHP_V}-fpm.sock;
    }
}
NGINX

echo "[4/4] Menerapkan konfigurasi dan auto-start..."
ln -sf /etc/nginx/sites-available/core.conf /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t

service php${PHP_V}-fpm restart
service nginx restart

grep -qxF 'service $(ls /etc/init.d/ | grep fpm) start && service nginx start' /root/.bashrc || \
echo 'service $(ls /etc/init.d/ | grep fpm) start && service nginx start' >> /root/.bashrc

echo "Setup Backend Core ($(hostname)) Sukses!"