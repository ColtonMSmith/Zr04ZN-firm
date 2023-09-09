#!/bin/sh
 WPA=/var/run/wpa_supplicant
 ifconfig eth0 down
 ifconfig wlan0 up
 if [  -e "$WPA" ] ; then
        echo "wpa is ok"
#        killall wpa_supplicant
#        usleep 1000000
#        wpa_supplicant -B -iwlan0 -c /mnt/mtd/wfcfg/wpa_supplicant.conf -Dwext
        usleep 300000
        wpa_cli scan
 else
        echo "wpa is not exist"
        wpa_supplicant -B -iwlan0 -c /mnt/mtd/wfcfg/wpa_supplicant.conf -Dwext
        usleep 4000000
        wpa_cli scan
 fi
