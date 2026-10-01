#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

echo "[1/4] Memasang Apache dan modul..."
apt-get update -y
apt-get install -y apache2
a2enmod autoindex remoteip

echo "[2/4] Membuat konten dokumen statis & arsip..."
mkdir -p /var/www/static/arsip
cat > /var/www/static/index.html <<HTML
<!doctype html>
<html>
<head><title>Static Backend - $(hostname)</title></head>
<body>
    <h1>Selamat Datang di Backend Statis ($(hostname) - Area Vault)</h1>
    <p>Server ini menangani aset statis.</p>
</body>
</html>
HTML

cat > /var/www/static/arsip/readme.txt <<'TXT'
Folder arsip dengan fitur Autoindex (Directory Listing) aktif.
TXT

chown -R www-data:www-data /var/www/static
chmod -R 755 /var/www/static

echo "[3/4] Mengonfigurasi VirtualHost & Real-IP..."
cat > /etc/apache2/sites-available/static.conf <<'APACHE'
<VirtualHost *:80>
    ServerName vault.k-39.com
    ServerAlias obladi.k-39.com desmond.k-39.com penny.k-39.com k-39.com www.k-39.com
    DocumentRoot /var/www/static
    DirectoryIndex index.html

    <Directory /var/www/static>
        Options FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    <Directory /var/www/static/arsip>
        Options +Indexes +FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    LogFormat "%a %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" vault_log
    ErrorLog ${APACHE_LOG_DIR}/static_error.log
    CustomLog ${APACHE_LOG_DIR}/static_access.log vault_log
</VirtualHost>
APACHE

cat << 'EOF' > /etc/apache2/conf-available/remoteip.conf
RemoteIPHeader X-Real-IP
RemoteIPHeader X-Forwarded-For
RemoteIPInternalProxy 10.83.3.2
RemoteIPInternalProxy 10.83.2.2
EOF

echo "[4/4] Menerapkan konfigurasi dan auto-start..."
a2enconf remoteip
a2dissite 000-default.conf 2>/dev/null || true
a2ensite static.conf

rm -f /var/run/apache2/apache2.pid
service apache2 restart

grep -qxF 'rm -f /var/run/apache2/apache2.pid && service apache2 start >/dev/null 2>&1' /root/.bashrc || \
echo 'rm -f /var/run/apache2/apache2.pid && service apache2 start >/dev/null 2>&1' >> /root/.bashrc

echo "Setup Backend Vault ($(hostname)) Sukses!"