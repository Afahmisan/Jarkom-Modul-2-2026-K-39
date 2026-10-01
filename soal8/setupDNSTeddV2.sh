#!/bin/bash

apt-get update
apt-get install bind9 -y

ln -s /etc/init.d/named /etc/init.d/bind9

mkdir -p /etc/bind/k-39

echo '
zone "k-39.com" {
    type slave;
    masters { 10.83.1.2; }; 
    file "/etc/bind/k-39/k-39.com"; 
};

zone "1.83.10.in-addr.arpa" {
    type slave;
    masters { 10.83.1.2; };
    file "/etc/bind/k-39/1.83.10.in-addr.arpa";
};

zone "2.83.10.in-addr.arpa" {
    type slave;
    masters { 10.83.1.2; };
    file "/etc/bind/k-39/2.83.10.in-addr.arpa";
};

zone "3.83.10.in-addr.arpa" {
    type slave;
    masters { 10.83.1.2; };
    file "/etc/bind/k-39/3.83.10.in-addr.arpa";
};

' > /etc/bind/named.conf.local



service bind9 restart