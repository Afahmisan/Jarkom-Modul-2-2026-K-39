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
};

zone "1.83.10.in-addr.arpa" {
  type master;
  notify yes;
  allow-transfer { 10.83.1.3; };
  file "/etc/bind/k-39/1.83.10.in-addr.arpa";
};

zone "2.83.10.in-addr.arpa" {
  type master;
  notify yes;
  allow-transfer { 10.83.1.3; };
  file "/etc/bind/k-39/2.83.10.in-addr.arpa";
};

zone "3.83.10.in-addr.arpa" {
  type master;
  notify yes;
  allow-transfer { 10.83.1.3; };
  file "/etc/bind/k-39/3.83.10.in-addr.arpa";
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
@       IN      A       10.83.3.2
;
rootkit IN      A       10.83.1.1
obladi  IN      A       10.83.1.4
desmond IN      A       10.83.1.5
oblada  IN      A       10.83.1.6
molly   IN      A       10.83.1.7

abbey   IN      A       10.83.2.2

penny   IN      A       10.83.3.2

delta   IN      A       10.83.4.2
epsilon IN      A       10.83.4.3

alpha   IN      A       10.83.5.2
beta    IN      A       10.83.5.3
gamma   IN      A       10.83.5.4

vault   IN      A       10.83.1.4
vault   IN      A       10.83.1.5

core    IN      A       10.83.1.6
core    IN      A       10.83.1.7
;

www     IN      CNAME   penny.k-39.com.
static  IN      CNAME   abbey.k-39.com.
;

' > /etc/bind/k-39/k-39.com

echo '$TTL    604800
@       IN      SOA     prab.k-39.com. root.k-39.com. (
                        2025100401 ; Serial
                        604800     ; Refresh
                        86400      ; Retry
                        2419200    ; Expire
                        604800 )   ; Negative Cache TTL

;
1.83.10.in-addr.arpa. IN      NS      prab.k-39.com.
1.83.10.in-addr.arpa. IN      NS      tedd.k-39.com.

2                     IN      PTR     prab.k-39.com.
3                     IN      PTR     tedd.k-39.com.

4                     IN      PTR     vault.k-39.com.
5                     IN      PTR     vault.k-39.com.

6                     IN      PTR     core.k-39.com.
7                     IN      PTR     core.k-39.com.
' > /etc/bind/k-39/1.83.10.in-addr.arpa

echo '$TTL    604800
@       IN      SOA     prab.k-39.com. root.k-39.com. (
                        2025100401 ; Serial
                        604800     ; Refresh
                        86400      ; Retry
                        2419200    ; Expire
                        604800 )   ; Negative Cache TTL

;
2.83.10.in-addr.arpa. IN      NS      prab.k-39.com.
2.83.10.in-addr.arpa. IN      NS      tedd.k-39.com.
;
2                     IN      PTR     abbey.k-39.com.

;' > /etc/bind/k-39/2.83.10.in-addr.arpa

echo '$TTL    604800
@       IN      SOA     prab.k-39.com. root.k-39.com. (
                        2025100401 ; Serial
                        604800     ; Refresh
                        86400      ; Retry
                        2419200    ; Expire
                        604800 )   ; Negative Cache TTL 
;
3.83.10.in-addr.arpa. IN      NS      prab.k-39.com.
3.83.10.in-addr.arpa. IN      NS      tedd.k-39.com.
;
2                     IN      PTR     penny.k-39.com.
;' > /etc/bind/k-39/3.83.10.in-addr.arpa

service bind9 restart