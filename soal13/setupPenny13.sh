#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

<<<<<<< HEAD
echo "[1/6] Memasang paket yang dibutuhkan..."
=======
echo "[1/5] Memasang dependensi Apache, utils, & PHP-FPM..."
>>>>>>> f8581fc (ATA)
apt-get update -y
apt-get install -y apache2 apache2-utils php-fpm

PHP_V=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')

<<<<<<< HEAD
echo "[2/6] Mengaktifkan modul Apache..."
a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests headers proxy_fcgi alias setenvif rewrite

echo "[3/6] Mengonfigurasi listener PHP-FPM (TCP 127.0.0.1:9000)..."
sed -i 's|^listen = .*|listen = 127.0.0.1:9000|' /etc/php/${PHP_V}/fpm/pool.d/www.conf
service $(ls /etc/init.d/ | grep fpm) restart

echo "[4/6] Menyiapkan folder /eternal dan /admin..."
# Jalur /eternal
=======
echo "[2/5] Mengaktifkan modul Apache..."
a2enmod rewrite proxy proxy_http proxy_balancer lbmethod_byrequests headers proxy_fcgi alias setenvif auth_basic authn_file authz_user

echo "[3/5] Listener PHP-FPM (127.0.0.1:9000)..."
sed -i 's|^listen = .*|listen = 127.0.0.1:9000|' /etc/php/${PHP_V}/fpm/pool.d/www.conf
service $(ls /etc/init.d/ | grep fpm) restart

echo "[4/5] Konten /eternal dan /admin..."
>>>>>>> f8581fc (ATA)
mkdir -p /var/www/eternal
cat << 'EOF' > /var/www/eternal/index.php
<?php
echo "PHP Rendering: OK | Waktu Server: " . date('Y-m-d H:i:s');
?>
EOF
chown -R www-data:www-data /var/www/eternal
chmod -R 755 /var/www/eternal

<<<<<<< HEAD
# Jalur /admin + Basic Auth
=======
>>>>>>> f8581fc (ATA)
mkdir -p /var/www/admin
cat << 'EOF' > /var/www/admin/index.html
<!doctype html>
<html>
<head><title>Ruang Rahasia Sindikat</title></head>
<body>
    <h1>Dokumen Rahasia Sindikat</h1>
    <p>Akses Diterima: Selamat datang di arsip dokumen terenkripsi.</p>
</body>
</html>
EOF
chown -R www-data:www-data /var/www/admin
chmod -R 755 /var/www/admin

htpasswd -bc /etc/apache2/.htpasswd prabs 'pakar_pinter_jadi_gob***'
chmod 640 /etc/apache2/.htpasswd
chown root:www-data /etc/apache2/.htpasswd

<<<<<<< HEAD
echo "[5/6] Memasang VirtualHost Apache (Redirect 301 + Kanonik www.k-39.com)..."
cat << 'EOF' > /etc/apache2/sites-available/vault-proxy.conf
# 1. REDIRECTOR: Default catch-all (Akses IP & domain penny.k-39.com) -> 301 ke www.k-39.com
<VirtualHost *:80>
    ServerName penny.k-39.com
    Redirect 301 / http://www.k-39.com/
</VirtualHost>

# 2. VHOST KANONIK UTAMA: www.k-39.com
<VirtualHost *:80>
    ServerName www.k-39.com
    ServerAlias k-39.com
    DocumentRoot /var/www

    # Pengecualian /eternal (PHP FastCGI)
    ProxyPass /eternal !
=======
echo "[5/5] Memasang VirtualHost Penny..."
cat << 'EOF' > /etc/apache2/sites-available/vault-proxy.conf
<VirtualHost *:80>
    ServerName www.k-39.com
    ServerAlias penny.k-39.com k-39.com 10.83.3.2
    DocumentRoot /var/www

    RewriteEngine On

    # 1. Redirect 301 jika bukan nama kanonik www.k-39.com
    RewriteCond %{HTTP_HOST} !^www\.k-39\.com$ [NC]
    RewriteRule ^(.*)$ http://www.k-39.com$1 [R=301,L]

    # 2. Tangani /eternal dan /admin di lokal, jangan dilempar ke Balancer
    RewriteCond %{REQUEST_URI} ^/eternal [OR]
    RewriteCond %{REQUEST_URI} ^/admin
    RewriteRule .* - [L]

    # Layanan PHP lokal
>>>>>>> f8581fc (ATA)
    Alias /eternal /var/www/eternal
    <Directory /var/www/eternal>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
        DirectoryIndex index.php index.html
        <FilesMatch \.php$>
            SetHandler "proxy:fcgi://127.0.0.1:9000"
        </FilesMatch>
    </Directory>

<<<<<<< HEAD
    # Pengecualian /admin (Basic Auth)
    ProxyPass /admin !
=======
    # Dokumen rahasia /admin (Basic Auth)
>>>>>>> f8581fc (ATA)
    Alias /admin /var/www/admin
    <Directory /var/www/admin>
        Options FollowSymLinks
        AllowOverride None
        DirectoryIndex index.html

        AuthType Basic
        AuthName "Area Rahasia Sindikat"
        AuthUserFile /etc/apache2/.htpasswd
        Require user prabs
    </Directory>

<<<<<<< HEAD
    # Cluster Balancer ke Area Vault (Obladi & Desmond)
=======
    # Balancer ke Vault (Obladi & Desmond)
>>>>>>> f8581fc (ATA)
    <Proxy balancer://vault_cluster>
        BalancerMember http://10.83.1.4:80 retry=1
        BalancerMember http://10.83.1.5:80 retry=1
        ProxySet lbmethod=byrequests
    </Proxy>

    ProxyPreserveHost On
    RequestHeader set X-Real-IP expr=%{REMOTE_ADDR}
    RequestHeader set X-Forwarded-For expr=%{REMOTE_ADDR}

<<<<<<< HEAD
    ProxyPass / balancer://vault_cluster/
=======
    RewriteRule ^/(.*)$ balancer://vault_cluster/$1 [P,L]
>>>>>>> f8581fc (ATA)
    ProxyPassReverse / balancer://vault_cluster/

    ErrorLog ${APACHE_LOG_DIR}/vault_proxy_error.log
    CustomLog ${APACHE_LOG_DIR}/vault_proxy_access.log combined
</VirtualHost>
EOF

<<<<<<< HEAD
echo "[6/6] Menerapkan konfigurasi dan auto-start..."
a2dissite 000-default.conf 2>/dev/null || true
a2ensite vault-proxy.conf
apache2ctl configtest

service php${PHP_V}-fpm restart
service apache2 restart

grep -qxF 'service $(ls /etc/init.d/ | grep fpm) start && service apache2 start' /root/.bashrc || \
echo 'service $(ls /etc/init.d/ | grep fpm) start && service apache2 start' >> /root/.bashrc

echo "Setup Penny Sukses!"
=======
rm -f /etc/apache2/sites-enabled/*
a2ensite vault-proxy.conf
apache2ctl configtest

killall -9 apache2 2>/dev/null || true
rm -f /var/run/apache2/apache2.pid
service apache2 start

echo "Setup Penny 13 Bersih & Siap Diuji!"
>>>>>>> f8581fc (ATA)
