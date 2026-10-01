#!/bin/bash

apt-get update
apt-get install apache2 -y

a2enmod autoindex

mkdir -p /var/www/static/arsip

cat > /var/www/static/index.html <<'HTML'
<!doctype html>
<html>
<head><title>Static Backend - VPC3</title></head>
<body>
    <h1>Selamat Datang di Backend Statis (VPC3 - Debian)</h1>
    <p>Server ini menangani aset statis.</p>
</body>
</html>
HTML

cat > /var/www/static/arsip/readme.txt <<'TXT'
Folder arsip dengan fitur Autoindex (Directory Listing) aktif.
TXT

chown -R www-data:www-data /var/www/static
chmod -R 755 /var/www/static

cat > /etc/apache2/sites-available/static.conf <<'APACHE'
<VirtualHost *:80>
    ServerName vault.k-39.com
    ServerAlias obladi.k-39.com desmond.k-39.com

    DocumentRoot /var/www/static
    DirectoryIndex index.html

    <Directory /var/www/static>
        Options FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    # Aktifkan fitur autoindex (Directory Listing) khusus direktori /arsip/
    <Directory /var/www/static/arsip>
        Options +Indexes +FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/static_error.log
    CustomLog ${APACHE_LOG_DIR}/static_access.log combined
</VirtualHost>
APACHE

a2dissite 000-default.conf || true
a2ensite static.conf
apache2ctl configtest
service apache2 restart