auto eth0
iface eth0 inet static
    address 10.83.3.2
    netmask 255.255.255.0
    gateway 10.83.3.1
    up echo -e "nameserver 10.83.1.2\nnameserver 10.83.1.3\nnameserver 192.168.122.1" > /etc/resolv.conf
    up /bin/bash /root/setupPenny11.sh