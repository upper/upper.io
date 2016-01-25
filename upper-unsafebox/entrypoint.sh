#!/bin/bash

iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

for DNS_SERVER_IP in $(echo -ne "8.8.8.8\n8.8.4.4"); do
  iptables -A OUTPUT -p udp -d $DNS_SERVER_IP --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
  iptables -A OUTPUT -p tcp -d $DNS_SERVER_IP --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
  iptables -A INPUT -p tcp -s $DNS_SERVER_IP --sport 53 -m state --state ESTABLISHED -j ACCEPT
  iptables -A INPUT -p udp -s $DNS_SERVER_IP --sport 53 -m state --state ESTABLISHED -j ACCEPT
done

iptables -A INPUT -i eth0 -p tcp --dport 8080 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 8080 -m state --state ESTABLISHED -j ACCEPT

iptables -A OUTPUT -o eth0 -p tcp --dport 5432 -d 104.131.92.227 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --sport 5432 -s 104.131.92.227 -m state --state ESTABLISHED -j ACCEPT

iptables -A OUTPUT -o eth0 -p tcp -m tcp --syn -j REJECT --reject-with icmp-host-prohibited

rm -rf $WORKDIR/c
mkdir -p $WORKDIR/c/usr/local/go
mkdir -p $WORKDIR/c/go
mkdir -p $WORKDIR/c/lib
mkdir -p $WORKDIR/c/lib64
mkdir -p $WORKDIR/c/tmp
mkdir -p $WORKDIR/c/dev
mkdir -p $WORKDIR/c/etc

#cp /etc/hosts $WORKDIR/c/etc/
#touch $WORKDIR/c/etc/resolv.conf

touch $WORKDIR/c/etc/hosts
touch $WORKDIR/c/etc/resolv.conf

echo "104.131.92.227 demo.upper.io" >> $WORKDIR/c/etc/hosts

echo "nameserver 8.8.8.8" >> $WORKDIR/c/etc/resolv.conf
echo "nameserver 8.8.4.4" >> $WORKDIR/c/etc/resolv.conf

mount -o bind /usr/local/go $WORKDIR/c/usr/local/go
mount -o bind /go $WORKDIR/c/go
mount -o bind /dev $WORKDIR/c/dev
mount -o bind /lib $WORKDIR/c/lib
mount -o bind /lib64 $WORKDIR/c/lib64

#mkdir -p $WORKDIR/c/bin
#mkdir -p $WORKDIR/c/usr/bin
#mkdir -p $WORKDIR/c/usr/lib
#mount -o bind /bin $WORKDIR/c/bin
#mount -o bind /usr/bin $WORKDIR/c/usr/bin
#mount -o bind /usr/lib $WORKDIR/c/usr/lib

chmod -R 755 $WORKDIR/c/go
chmod -R 755 $WORKDIR/c/usr/local/go

mount -t tmpfs -o size=800m tmpfs $WORKDIR/c/tmp

chroot --userspec sandbox:sandbox $WORKDIR/c go/bin/sandbox
