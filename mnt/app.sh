ifconfig eth0 192.168.1.161
ifconfig lo up
#telnetd&

#mkdir -p /mnt/mtd1
#mount -t nfs -o nolock -o tcp 192.168.1.177:/opt/nfs /mnt/mtd1

#############################################
rm -rf /mnt/mtd/modules/
mkdir /mnt/mtd/modules
mount -t tmpfs -o size=25M tmpfs /mnt/mtd/modules/
cd /mnt/mtd/modules/
tar -zxf /mnt/mtd/modules.tar.gz
tar -zxf /mnt/mtd/td3515.tar.gz
#tar -zxf /mnt/mtd/WebSites.tar.gz

chmod 777 load3520D
./load3520D -i

#cd /mnt/mtd
#umount modules
#rm -rf modules

chmod -R 777 /mnt/mtd/nts/
#############################################
/mnt/mtd/boot.sh
#############################################


