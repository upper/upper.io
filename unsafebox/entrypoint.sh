#!/bin/bash

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

echo "hosts: files dns" > $WORKDIR/c/etc/nsswitch.conf

mount -o ro,bind /usr/local/go $WORKDIR/c/usr/local/go
mount -o ro,bind /go $WORKDIR/c/go
mount -o ro,bind /dev $WORKDIR/c/dev
mount -o ro,bind /lib $WORKDIR/c/lib
mount -o ro,bind /lib64 $WORKDIR/c/lib64

touch $WORKDIR/c/etc/resolv.conf
mount -o ro,bind /etc/resolv.conf $WORKDIR/c/etc/resolv.conf

chmod -R 755 $WORKDIR/c/go
chmod -R 755 $WORKDIR/c/usr/local/go

mount -t tmpfs -o size=800m tmpfs $WORKDIR/c/tmp

chroot --userspec sandbox:sandbox $WORKDIR/c /bin/playground
