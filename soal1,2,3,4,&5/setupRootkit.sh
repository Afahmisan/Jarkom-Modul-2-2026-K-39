auto eth0
iface eth0 inet dhcp
    up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    up iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
    up iptables -A FORWARD -i eth2 -o eth0 -j ACCEPT
    up iptables -A FORWARD -i eth3 -o eth0 -j ACCEPT
    up iptables -A FORWARD -i eth4 -o eth0 -j ACCEPT
    up iptables -A FORWARD -i eth5 -o eth0 -j ACCEPT
    up iptables -A FORWARD -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
    up sysctl -w net.ipv4.ip_forward=1

auto eth1
iface eth1 inet static
    address 10.83.1.1
    netmask 255.255.255.0

auto eth2
iface eth2 inet static
    address 10.83.2.1
    netmask 255.255.255.0

auto eth3
iface eth3 inet static
    address 10.83.3.1
    netmask 255.255.255.0

auto eth4
iface eth4 inet static
    address 10.83.4.1
    netmask 255.255.255.0

auto eth5
iface eth5 inet static
    address 10.83.5.1
    netmask 255.255.255.0
