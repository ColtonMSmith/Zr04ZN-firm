#!/bin/sh

UpdateStatus=/mnt/mtd/Update.dat
UpdateFileName=/mnt/mtd/UpFile.dat
PreProductCheck=/upgrade/

FindeUsb()
{
	TIME=0
	while [ true ] ; do
		filelist=$(ls /sys/block/sd*/removable)
		if [ "$filelist" = "" ] ; then	
			echo "$0: please insert USB disk and Upgrate!"
		else
			for i in  ${filelist}; do \
				if [ -r $i ] ; then
					REMOVE=`cat "$i"`
					if [ "$REMOVE" = "1" ] ; then
						export USBDISK=${i}
						export DEV=$(expr substr $i 12 3)
						break
					fi
				fi
			done
		fi
			
		if [ "$DEV" != "" ] ; then
			break
		fi
		echo "$0: please insert USB disk and Upgrate!"
		sleep 2
    		TIME=`expr $TIME + 1`
    		if [ $TIME -gt 30 ] ; then
			echo "$0: time out for find usb disk, now reboot and try again!"
			sleep 2				
			break
    		fi
	done
	if [ "$DEV" != "" ] ; then
		echo "$0: usb disk is : ${USBDISK}"
	else
		echo "$0: time out for find usb disk!"				
	fi
}

Update()
{
	#mount USB设备到 /mnt/usbdir 目录下
	umount /mnt/usbdir
	rm -rf /mnt/usbdir
	mkdir /mnt/usbdir	
	mount -t vfat /dev/${DEV} /mnt/usbdir > /dev/null
	if [ $? -ne 0 ] ; then
		mount -t vfat /dev/${DEV}1 /mnt/usbdir > /dev/null 
	fi
	
	#检查是否存在UpdateFileName=/mnt/mtd/UpFile.dat
	ls ${UpdateFileName}
	if [ "$?" != 0 ] ; then		
		umount /mnt/usbdir
		rm -rf /mnt/usbdir
		echo 0 > ${UpdateStatus}		
		rm -rf ${UpdateFileName}		
	else
		PACKAGEFILE=$(cat ${UpdateFileName})
		PACKAGEFILEPATH=/mnt/usbdir/${PACKAGEFILE}
		echo ${PACKAGEFILEPATH}
		
		#检查打包文件是否存在 
		if [ ! -e "${PACKAGEFILEPATH}" ] ; then
			#升级失败，就不在等待再次升级，直接运行原来的程序。
			umount /mnt/usbdir
			rm -rf /mnt/usbdir
			echo "Do not exists *.tar file or exists much than one *.tar files  in USB disk, please check"
			echo 0 > ${UpdateStatus}		
			rm -rf ${UpdateFileName}
		else
			#拷贝升级文件到内存中
			rm -rf /nfsdir/run
			mkdir  /nfsdir/run
			cp  -rf   ${PACKAGEFILEPATH}   /nfsdir/run
			if [ "$?" != 0 ] ; then                                      
				echo " Error occur during copy file to memory, please check"
				umount /mnt/usbdir
				rm -rf /mnt/usbdir
				rm -rf /nfsdir/run
				echo 0 > ${UpdateStatus}			
				rm -rf ${UpdateFileName}
			else
				echo "Copy update file to memory successfully, now you can remove USB disk"
				#检查打包文件是否存在
				if [ ! -e "${PACKAGEFILEPATH}" ] ; then
					echo "Do not exists *.tar file or exists much than one *.tar files  in /run directory, please check"
					umount /mnt/usbdir
					rm -rf /mnt/usbdir
					rm -rf /nfsdir/run				
					echo 0 > ${UpdateStatus}				
					rm -rf ${UpdateFileName}
				else
					echo "=================================================================================="
					echo "Begin Upgrate!"
					#echo 0 > ${UpdateStatus}				
					#rm -rf ${UpdateFileName}
					#cd /mnt/mtd/
					#tar -czvf /nfsdir/old.tar *
					#if [ "$?" != "0" ] ; then
					#	echo "backup old version failed. so no upgrade."
					#else
						cd /mnt/mtd
						ls /mnt/mtd | sed "s:^:"/mnt/mtd"/:" | grep -v "UpFile.dat" | grep -v "boot.sh"  > tempfile
						rm -rf `cat tempfile`
						rm -rf `cat tempfile`
						rm -rf `cat tempfile`
						rm tempfile
						tar -xzvf ${PACKAGEFILEPATH} -C /mnt/mtd
						if [ "$?" = "0" ] ; then
							rm -rf /lib/libhi3515.so
							rm -rf /lib/libtsnetdevice.so
							#cp -rf /mnt/mtd/libhi3520.so /lib/
							#cp -rf /mnt/mtd/libtsnetdevice.so /lib/
							rm -rf /mnt/mtd/productcheck
							rm -rf /upgrade/productcheck
							rm -rf /upgrade/check.dat
							echo 0 > ${UpdateStatus}
							chmod 666 ${UpdateStatus}
							echo "update succ"					
						else
							echo " go back to old version"
							cd /mnt/mtd
							ls /mnt/mtd | sed "s:^:"/mnt/mtd"/:" | grep -v "UpFile.dat" | grep -v "boot.sh"  > tempfile
							rm -rf `cat tempfile`
							rm -rf `cat tempfile`
							rm -rf `cat tempfile`
							rm tempfile
							#tar -xzvf /nfsdir/old.tar -C /mnt/mtd
						fi
					#fi
					umount /mnt/usbdir
					rm -rf /mnt/usbdir
					rm -rf /nfsdir/run
					#rm -rf /nfsdir/old.tar
					echo "$0: Complete Upgrate!"
					echo "=================================================================================="
					reboot
#					/mnt/d6316_reboot
				fi	
			fi
		fi
	fi		
	
}


#先查找U盘
FindeUsb

#如果找到就升级，没有就不升级
if [ "$DEV" != "" ] ; then
	Update
else
	echo "do not find file,so no upgrade."
	echo 0 > ${UpdateStatus}
	rm -rf ${UpdateFileName}
fi   			

/mnt/mtd/td3515 &
