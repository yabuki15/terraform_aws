#!/bin/bash
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p
yum install -y iptables-services
systemctl enable iptables
systemctl start iptables
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
service iptables save