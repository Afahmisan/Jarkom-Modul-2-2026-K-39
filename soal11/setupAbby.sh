#!/bin/bash
<<<<<<< HEAD
=======
set -e
>>>>>>> f8581fc (ATA)

apt-get update
apt-get install nginx -y

<<<<<<< HEAD
=======
# 1. Tulis konfigurasi VirtualHost Abbey
>>>>>>> f8581fc (ATA)
cat << 'EOF' > /etc/nginx/sites-available/abbey-proxy
upstream core_cluster {
    server 10.83.1.6:80;
    server 10.83.1.7:80;
}

server {
    listen 80;
    server_name abbey.k-39.com _;

    location / {
        proxy_pass http://core_cluster;

<<<<<<< HEAD
        # Teruskan Host dan IP asli pengunjung
=======
        # Teruskan Host dan IP asli pengunjung sesuai instruksi Soal 11
>>>>>>> f8581fc (ATA)
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

<<<<<<< HEAD
ln -sf /etc/nginx/sites-available/abbey-proxy /etc/nginx/sites-enabled/default
nginx -t && service nginx restart
=======
rm -f /etc/nginx/sites-enabled/*

ln -sf /etc/nginx/sites-available/abbey-proxy /etc/nginx/sites-enabled/abbey-proxy

nginx -t
service nginx restart
>>>>>>> f8581fc (ATA)
