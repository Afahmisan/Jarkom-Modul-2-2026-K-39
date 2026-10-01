#!/bin/bash
set -e

apt-get update
apt-get install nginx php-fpm -y

PHP_V=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')
service php${PHP_V}-fpm start

mkdir -p /var/www/core

cat > /var/www/core/index.php <<'PHP'
<!doctype html>
<html>
<head>
    <title>Core Area - Beranda</title>
</head>
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
<head>
    <title>Core Area - Profil</title>
</head>
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

cat > /etc/nginx/sites-available/core.conf <<NGINX
server {
    listen 80;
    server_name core.k-39.com oblada.k-39.com molly.k-39.com;

    root /var/www/core;
    index index.php index.html;

    # Aturan Rewrite: URL bersih /profil langsung diarahkan ke profil.php
    rewrite ^/profil/?$ /profil.php last;

    location / {
        try_files \$uri \$uri/ =404;
    }

    # Teruskan eksekusi PHP ke FastCGI PHP-FPM
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php${PHP_V}-fpm.sock;
    }
}
NGINX

ln -sf /etc/nginx/sites-available/core.conf /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t
service nginx restart