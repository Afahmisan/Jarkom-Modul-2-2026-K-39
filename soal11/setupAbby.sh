#!/bin/bash

apt-get update
apt-get install nginx -y

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

        # Teruskan Host dan IP asli pengunjung
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

ln -sf /etc/nginx/sites-available/abbey-proxy /etc/nginx/sites-enabled/default
nginx -t && service nginx restart