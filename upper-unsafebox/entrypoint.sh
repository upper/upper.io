#!/bin/bash

#iptables -P INPUT DROP
#iptables -P FORWARD DROP
#iptables -P OUTPUT DROP

#iptables -A INPUT -i eth0 -p tcp --dport 8080 -m state --state NEW,ESTABLISHED -j ACCEPT
#iptables -A OUTPUT -o eth0 -p tcp --sport 8080 -m state --state ESTABLISHED -j ACCEPT

#iptables -A OUTPUT -o eth0 -p tcp -m tcp --syn -j REJECT --reject-with icmp-host-prohibited

rm -rf $WORKDIR/c

mkdir -p $WORKDIR/c/bin
mkdir -p $WORKDIR/c/usr/local/go
mkdir -p $WORKDIR/c/go
mkdir -p $WORKDIR/c/lib
mkdir -p $WORKDIR/c/lib64
mkdir -p $WORKDIR/c/tmp
mkdir -p $WORKDIR/c/dev
mkdir -p $WORKDIR/c/etc

cp /app/playground $WORKDIR/c/bin

mount -o bind /usr/local/go $WORKDIR/c/usr/local/go
mount -o bind /go $WORKDIR/c/go
mount -o bind /dev $WORKDIR/c/dev
mount -o bind /lib $WORKDIR/c/lib
mount -o bind /lib64 $WORKDIR/c/lib64

chmod -R 755 $WORKDIR/c/go
chmod -R 755 $WORKDIR/c/usr/local/go

mount -t tmpfs -o size=800m tmpfs $WORKDIR/c/tmp

chroot --userspec sandbox:sandbox $WORKDIR/c /bin/playground
