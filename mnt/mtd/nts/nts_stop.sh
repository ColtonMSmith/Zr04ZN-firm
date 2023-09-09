#!/bin/sh

echo "==========================================="
echo "stop ntsclientcon_hisiv300"

cd /mnt/mtd/nts
killall ntsclientcon_hisiv300
cd -

echo "==========================================="

