#!/system/bin/sh
# By Genokolar 2011/02/07

# read conf
if [ -e /system/etc/enhanced.conf ]
then
BACKUPMODE=`busybox grep BACKUPMODE /system/etc/enhanced.conf |busybox cut -d= -f2 `
else
BACKUPMODE="1"
fi


# MODE ONE Restore from sd-ext
if [ $BACKUPMODE = 0 ]
then
  ## Mount SD-EXT
  if [ -e /dev/block/mmcblk0p2 -a -e /system/etc/.nomount ]
  then
  mount -t ext4 /dev/block/mmcblk0p2 /sd-ext
  busybox touch /sd-ext/test
  if [ -e /sd-ext/test ]
  then
  busybox rm -f /system/etc/.nomount
  busybox rm -f /sd-ext/test
  echo Mount SD-ext... >> /system/log.txt
  echo 已开启SD-EXT分区和增强功能，再运行此命令即可使用增强功能
  exit
  fi
  fi
  ## if data2ext on
  if [ -d /system/etc/data2ext-run -a -e /dev/block/mmcblk0p2 -a -d /sd-ext/data -a -d /sd-ext/system ]
  then
    ### restore wifi data
    if [ -e /system/etc/restorying ]
    then
    busybox rm -rf /data/misc/wifi
    busybox cp -rp /sd-ext/wifi /data/misc/
    echo `busybox date +%F" "%T` Restory wifi DATA from sd-ext... >> /system/log.txt
    echo "Geno：已开启data2ext，只还原了wifi数据，其他数据无需还原"
    ### prepare restore wifi data
    elif [ -d /sd-ext/wifi ]
    then
    backupfile=`busybox ls /sd-ext/*.backup |busybox cut -d/ -f3`
    backupdate=${backupfile%.backup}
    busybox touch /system/etc/restorying
    start timing
    echo Geno：你开启了data2ext，只能还原WIFI数据，你准备还原的WIFI数据的备份时间为：$backupdate ，如果你确认要还原WIFI数据，请在一分钟之内再次运行此命令
    ### do nothing
    else
    echo Geno：你开启了data2ext，我没有发现备份的WIFI数据，所以我什么也没干
    fi
  ## if no data2ext exist backup
  elif [ -e /dev/block/mmcblk0p2 -a -d /sd-ext/data -a -d /sd-ext/system -a -d /sd-ext/wifi -a -e /sd-ext/*.backup ]
  then
    ### restore all data
    if [ -e /system/etc/restorying ]
    then
    bakdir=`ls /sd-ext/data`
    for data in $bakdir 
    do
      if [ -d /data/data/$data ]
      then
      busybox rm -rf /data/data/$data
      busybox cp -rp /sd-ext/data/$data /data/data
      fi
    done
    busybox rm -rf /data/system
    busybox cp -rp /sd-ext/system /data/system
    busybox rm -rf /data/misc/wifi
    busybox cp -rp /sd-ext/wifi /data/misc/
    echo `busybox date +%F" "%T` Restory all DATA from sd-ext... >> /system/log.txt
    sync
    reboot
    ### prepare restore all data
    else
    backupfile=`busybox ls /sd-ext/*.backup |busybox cut -d/ -f3`
    backupdate=${backupfile%.backup}
    busybox touch /system/etc/restorying
    start timing
    echo Geno：你准备从SD-EXT还原的数据的备份时间为：$backupdate ，如果你确认要还原，请在一分钟之内再次运行此命令
    fi
  else
  echo Geno：没找到完整备份数据，请确认你备份了数据。
  fi
# MODE TWO Restore from sdcard
elif [ $BACKUPMODE = 1 ]
then
  if [ -e /sdcard/Gbackup/system.tar -a -e /sdcard/Gbackup/data.tar -a -e /sdcard/Gbackup/wifi.tar ]
  then
    ## restore all data
    if [ -e /system/etc/restorying ]
    then
    busybox rm -rf /data/misc/wifi
    busybox tar -xpf /sdcard/Gbackup/wifi.tar
    busybox rm -rf /data/system
    busybox tar -xpf /sdcard/Gbackup/system.tar
    busybox rm -rf /data/data
    busybox tar -xpf /sdcard/Gbackup/data.tar
    echo `busybox date +%F" "%T` Restory all DATA from sdcard... >> /system/log.txt
    sync
    reboot
    ## prepare restore all data
    else
    backupfile=`busybox ls /sdcard/Gbackup/*.backup |busybox cut -d/ -f4`
    backupdate=${backupfile%.backup}
    busybox touch /system/etc/restorying
    start timing
    echo Geno：你准备从Sdcard还原的数据的备份时间为：$backupdate ，如果你确认要还原，请在一分钟之内再次运行此命令
    fi
  else
  echo Geno：没找到完整备份数据，请确认你备份了数据。
  fi
# MODE TWO Restore from sdcard
elif [ $BACKUPMODE = 2 ]
then
  if [ -e /sdcard/Gbackup/system.tar -a -e /sdcard/Gbackup/data.tar -a -e /sdcard/Gbackup/wifi.tar -a -e /sdcard/Gbackup/app.tar ]
  then
    ## restore app and data
    if [ -e /system/etc/restorying ]
    then
      if [ -d /system/etc/app2sd-run ]
      then
      busybox rm -f /sd-ext/app/*.apk
      busybox tar -xpf /sdcard/Gbackup/app.tar
      else
      busybox rm -rf /data/app
      busybox tar -xpf /sdcard/Gbackup/app.tar
      fi
    busybox rm -rf /data/misc/wifi
    busybox tar -xpf /sdcard/Gbackup/wifi.tar
    busybox rm -rf /data/system
    busybox tar -xpf /sdcard/Gbackup/system.tar
    busybox rm -rf /data/data
    busybox tar -xpf /sdcard/Gbackup/data.tar
    echo `busybox date +%F" "%T` Restory APP and DATA from sdcard... >> /system/log.txt
    sync
    reboot
    ### prepare restore app and data
    else
    backupfile=`busybox ls /sdcard/Gbackup/*.backup |busybox cut -d/ -f4`
    backupdate=${backupfile%.backup}
    busybox touch /system/etc/restorying
    start timing
    echo Geno：你准备从Sdcard还原的程序和数据的备份时间为：$backupdate ，如果你确认要还原，请在一分钟之内再次运行此命令
    fi
  else
  echo Geno：没找到完整备份数据，请确认你备份了数据。
  fi
fi
exit
