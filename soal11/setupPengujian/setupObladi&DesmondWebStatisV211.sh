#!/bin/bash


apt-get update
apt-get install apache2 -y

# Aktifkan modul yang dibutuhkan
a2enmod autoindex remoteip

mkdir -p /var/www/static/arsip

# Nama server dinamis sesuai nama container (Obladi atau Desmond)
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

# Konfigurasi VirtualHost lengkap dengan deklarasi Log asli
cat > /etc/apache2/sites-available/static.conf <<'APACHE'
<VirtualHost *:80>
    ServerName vault.k-39.com
    ServerAlias obladi.k-39.com desmond.k-39.com penny.k-39.com k-39.com
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

    # Deklarasi log independen membaca IP asli klien (%a)
    LogFormat "%a %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" vault_log
    ErrorLog ${APACHE_LOG_DIR}/static_error.log
    CustomLog ${APACHE_LOG_DIR}/static_access.log vault_log
</VirtualHost>
APACHE

# Konfigurasi RemoteIP membaca header dari Penny dan Abbey
cat << 'EOF' > /etc/apache2/conf-available/remoteip.conf
RemoteIPHeader X-Real-IP
RemoteIPHeader X-Forwarded-For
RemoteIPInternalProxy 10.83.3.2
RemoteIPInternalProxy 10.83.2.2
EOF

# Aktifkan modul dan site
a2enconf remoteip
a2dissite 000-default.conf 2>/dev/null || true
a2ensite static.conf

# Bersihkan port 80 dan jalankan Apache bersih
killall -9 apache2 nginx 2>/dev/null || true
service apache2 start

# Pastikan Apache otomatis menyala saat node di-reboot
update-rc.d apache2 defaults 2>/dev/null || true