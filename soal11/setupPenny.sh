
#!/bin/bash
set -e

service nginx stop 2>/dev/null || true
apt-get purge nginx nginx-common -y 2>/dev/null || true
killall -9 nginx 2>/dev/null || true

apt-get update
apt-get install apache2 php-fpm -y

a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests headers proxy_fcgi alias setenvif

PHP_FPM_CONF=$(ls /etc/php/*/fpm/pool.d/www.conf | head -n 1)
sed -i 's|^listen = .*|listen = 127.0.0.1:9000|' "$PHP_FPM_CONF"
service $(ls /etc/init.d/ | grep fpm) restart

mkdir -p /var/www/eternal

cat << 'EOF' > /var/www/eternal/index.php
<?php
echo "PHP Rendering: OK | Waktu Server: " . date('Y-m-d H:i:s');
?>
EOF

chown -R www-data:www-data /var/www/eternal
chmod -R 755 /var/www/eternal

cat << 'EOF' > /etc/apache2/sites-available/vault-proxy.conf
<VirtualHost *:80>
    ServerName penny.k-39.com
    ServerAlias k-39.com
    DocumentRoot /var/www

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

    <Proxy balancer://vault_cluster>
        BalancerMember http://10.83.1.4:80
        BalancerMember http://10.83.1.5:80
        ProxySet lbmethod=byrequests
    </Proxy>

    ProxyPreserveHost On
    RequestHeader set X-Real-IP expr=%{REMOTE_ADDR}
    RequestHeader set X-Forwarded-For expr=%{REMOTE_ADDR}

    ProxyPass / balancer://vault_cluster/
    ProxyPassReverse / balancer://vault_cluster/

    ErrorLog ${APACHE_LOG_DIR}/vault_proxy_error.log
    CustomLog ${APACHE_LOG_DIR}/vault_proxy_access.log combined
</VirtualHost>
EOF

a2dissite 000-default.conf 2>/dev/null || true
a2ensite vault-proxy.conf

apache2ctl configtest

killall -9 apache2 2>/dev/null || true
rm -f /var/run/apache2/apache2.pid
service apache2 start

grep -qxF 'service $(ls /etc/init.d/ | grep fpm) start && service apache2 start' /root/.bashrc || \
echo 'service $(ls /etc/init.d/ | grep fpm) start && service apache2 start' >> /root/.bashrc
