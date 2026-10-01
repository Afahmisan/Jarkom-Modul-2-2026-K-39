#!/bin/bash
set -e

<<<<<<< HEAD
export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y apache2 apache2-utils php-fpm

PHP_V=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')

a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests headers proxy_fcgi alias setenvif

sed -i 's|^listen = .*|listen = 127.0.0.1:9000|' /etc/php/${PHP_V}/fpm/pool.d/www.conf
service $(ls /etc/init.d/ | grep fpm) restart

# Path /eternal
=======
# Bersihkan sisa proses atau paket yang berpotensi bentrok di port 80
service nginx stop 2>/dev/null || true
apt-get purge nginx nginx-common -y 2>/dev/null || true
killall -9 nginx 2>/dev/null || true

apt-get update
apt-get install apache2 apache2-utils php-fpm -y

a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests headers proxy_fcgi alias setenvif auth_basic authn_file authz_user

PHP_FPM_CONF=$(ls /etc/php/*/fpm/pool.d/www.conf | head -n 1)
sed -i 's|^listen = .*|listen = 127.0.0.1:9000|' "$PHP_FPM_CONF"
service $(ls /etc/init.d/ | grep fpm) restart

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
# Path /admin
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

<<<<<<< HEAD
# Kredensial Basic Authentication
=======
>>>>>>> f8581fc (ATA)
htpasswd -bc /etc/apache2/.htpasswd prabs 'pakar_pinter_jadi_gob***'
chmod 640 /etc/apache2/.htpasswd
chown root:www-data /etc/apache2/.htpasswd

cat << 'EOF' > /etc/apache2/sites-available/vault-proxy.conf
<VirtualHost *:80>
    ServerName penny.k-39.com
    ServerAlias k-39.com
    DocumentRoot /var/www

<<<<<<< HEAD
    # 1. Pengecualian /eternal (Layanan PHP Lokal)
=======
    # --- Pengecualian 1: /eternal (Layanan PHP FastCGI Lokal) ---
>>>>>>> f8581fc (ATA)
    ProxyPass /eternal !
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
    # 2. Pengecualian /admin (Basic Auth Lokal)
=======
    # --- Pengecualian 2: /admin (Dokumen Rahasia Sindikat + Basic Auth) ---
>>>>>>> f8581fc (ATA)
    ProxyPass /admin !
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
    # 3. Cluster Load Balancer ke Area Vault (Obladi & Desmond)
=======
    # --- Cluster Load Balancer ke Area Vault (Obladi & Desmond) ---
>>>>>>> f8581fc (ATA)
    <Proxy balancer://vault_cluster>
        BalancerMember http://10.83.1.4:80 retry=1
        BalancerMember http://10.83.1.5:80 retry=1
        ProxySet lbmethod=byrequests
    </Proxy>

<<<<<<< HEAD
    # 4. Penerusan Host dan IP Asli Klien
=======
    # Teruskan Host dan IP asli pengunjung sesuai Soal 11
>>>>>>> f8581fc (ATA)
    ProxyPreserveHost On
    RequestHeader set X-Real-IP expr=%{REMOTE_ADDR}
    RequestHeader set X-Forwarded-For expr=%{REMOTE_ADDR}

<<<<<<< HEAD
    # 5. Routing Utama ke Cluster Vault
=======
    # Distribusi lalu lintas root ke cluster Vault
>>>>>>> f8581fc (ATA)
    ProxyPass / balancer://vault_cluster/
    ProxyPassReverse / balancer://vault_cluster/

    ErrorLog ${APACHE_LOG_DIR}/vault_proxy_error.log
    CustomLog ${APACHE_LOG_DIR}/vault_proxy_access.log combined
</VirtualHost>
EOF

a2dissite 000-default.conf 2>/dev/null || true
a2ensite vault-proxy.conf
<<<<<<< HEAD
apache2ctl configtest

service php${PHP_V}-fpm restart
service apache2 restart

update-rc.d php${PHP_V}-fpm defaults 2>/dev/null || true
update-rc.d apache2 defaults 2>/dev/null || true

echo "Node Penny berhasil dikonfigurasi secara menyeluruh."
=======

apache2ctl configtest

killall -9 apache2 2>/dev/null || true
rm -f /var/run/apache2/apache2.pid
service apache2 start

grep -qxF 'service $(ls /etc/init.d/ | grep fpm) start && service apache2 start' /root/.bashrc || \
echo 'service $(ls /etc/init.d/ | grep fpm) start && service apache2 start' >> /root/.bashrc

echo "Setup Penny (Soal 11 & 12) Berhasil Diterapkan!"
>>>>>>> f8581fc (ATA)
