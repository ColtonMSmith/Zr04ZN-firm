#!/bin/sh

UpdateStatus=/mnt/mtd/Update.dat
PreUpgradeSh=/upgrade/preupgrade.sh

######################################
cd /mnt/mtd/
./mkscfifo&
cd -
######################################

rm /nfsdir -rf
#mkdir /nfsdir
#mount -t tmpfs tmpfs /nfsdir


rm /lib/libhi3515.so
ln -s /mnt/mtd/libhi3515.so  /lib/libhi3515.so

# 检查文件是否存在和可读
if [ ! -e "$UpdateStatus" -o ! -r "$UpdateStatus" ] ; then
	#为空，表示刚才在升级时，进行了重启。所以需要在次升级
	echo 1 > ${UpdateStatus}
	chmod 666 ${UpdateStatus}
fi

RESULT=`cat "$UpdateStatus"`
if [ "$RESULT" = "1" ] ; then
	ls ${PreUpgradeSh}
	if [ "$?" != 0 ] ; then 
		echo 0 > ${UpdateStatus}
               cd /mnt/mtd/                                         
               rm -rf config/                                       
               ln -s /mnt/config/ /mnt/mtd/config
		/mnt/mtd/modules/td3515 &
	else
		mkdir /nfsdir
		mount -t tmpfs tmpfs /nfsdir
		sh ${PreUpgradeSh}			
	fi		
else
	echo "No need to recovery program from USB"
	cd /mnt/mtd/
	rm -rf config/
	ln -s /mnt/config/ /mnt/mtd/config
	/mnt/mtd/modules/td3515 &
fi
#############################################
cd /mnt/mtd
umount modules
rm -rf modules
#############################################
