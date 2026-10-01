#!/bin/bash

apt-get update
apt-get install bind9 -y

ln -s /etc/init.d/named /etc/init.d/bind9
echo '
zone "k-39.com" {
  type master;
  notify yes;
  allow-transfer { 10.83.1.3; };
  file "/etc/bind/k-39/k-39.com";
};' > /etc/bind/named.conf.local

echo 'options {
  directory "/var/cache/bind";

  forwarders {
    192.168.122.1;
  };

  dnssec-validation no;
  allow-query { any; };
  auth-nxdomain no;
  listen-on-v6 { any; };
};' > /etc/bind/named.conf.options

mkdir -p /etc/bind/k-39

echo '$TTL    604800
@       IN      SOA     prab.k-39.com. root.k-39.com. (
                        2025100401 ; Serial
                        604800     ; Refresh
                        86400      ; Retry
                        2419200    ; Expire
                        604800 )   ; Negative Cache TTL
;
@       IN      NS      prab.k-39.com.
@       IN      NS      tedd.k-39.com.
;
prab    IN      A       10.83.1.2
tedd    IN      A       10.83.1.3
;
@       IN      A       10.83.3.2' > /etc/bind/k-39/k-39.com

service bind9 restart