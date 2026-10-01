#!/bin/bash

apt-get update
apt-get install bind9 -y

ln -s /etc/init.d/named /etc/init.d/bind9

echo 'zone "k-39.com" {
    type slave;
    masters { 10.83.1.2; }; 
    file "/etc/bind/k-39/k-39.com"; 
};' > /etc/bind/named.conf.local

service bind9 restart