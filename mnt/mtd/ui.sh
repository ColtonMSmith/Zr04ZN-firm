#!/bin/sh

cd /mnt/mtd
rm ui -rf
mkdir ui
mount -t tmpfs -o size=9M tmpfs ui
cd ui

tar -zxf ../ui.tar.gz

