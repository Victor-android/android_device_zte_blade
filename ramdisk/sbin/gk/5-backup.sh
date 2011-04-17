#!/system/bin/sh
# By Genokolar 2011/02/07

# read conf
if [ -e /system/etc/enhanced.conf ]
then
BACKUPMODE=`busybox grep BACKUPMODE /system/etc/enhanced.conf |busybox cut -d= -f2 `
else
BACKUPMODE="1"
fi


# MODE ONE backup to sd-ext
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
    ### backup wifi
    if [ -e /system/etc/backuping ]
    then
    NOWDATE=`busybox date +%F-%H-%M-%S`
    busybox rm -f /sd-ext/*.backup
    busybox touch /sd-ext/$NOWDATE.backup
    busybox rm -rf /sd-ext/wifi
    busybox cp -rp /data/misc/wifi /sd-ext/
    busybox rm -f /system/etc/backuping
    echo `busybox date +%F" "%T` Backup wifi DATA to sd-ext... >> /system/log.txt
    echo "Geno：已开启data2ext，只备份了wifi数据，其他数据无需备份"
    exit
    ### prepare backup wifi data
    else
    backupfile=`busybox ls /sd-ext/*.backup |busybox cut -d/ -f3`
    backupdate=${backupfile%.backup}
    busybox touch /system/etc/backuping
    start timing
    echo Geno：发现你EXT分区已经存在备份时间为：$backupdate 的WIFI数据，如果确认要备份新WIFI数据,请在一分钟之内再次运行此命令
    exit
    fi
  ## if no data2ext and backuped
  elif [ -e /dev/block/mmcblk0p2 -a -d /sd-ext/data -a -d /sd-ext/system -a -d /sd-ext/wifi -a -e /sd-ext/*.backup ]
  then
    ### backup all data
    if [ -e /system/etc/backuping ]
    then
    busybox rm -rf /sd-ext/data
    busybox cp -rp /data/data /sd-ext/
    busybox rm -rf /sd-ext/system
    busybox cp -rp /data/system /sd-ext/
    busybox rm -rf /sd-ext/wifi
    busybox cp -rp /data/misc/wifi /sd-ext/
    nowdate=`busybox date +%F-%H-%M-%S`
    busybox rm -f /sd-ext/*.backup
    busybox touch /sd-ext/$nowdate.backup
    busybox rm -f /system/etc/backuping
    echo `busybox date +%F" "%T` Backup all DATA to sd-ext... >> /system/log.txt
    echo "Geno：数据及设置已经备份到sd-ext"
    exit
    ### prepare backup all data
    else
    backupfile=`busybox ls /sd-ext/*.backup |busybox cut -d/ -f3`
    backupdate=${backupfile%.backup}
    busybox touch /system/etc/backuping
    start timing
    echo Geno：发现你EXT分区已经存在备份时间为：$backupdate 的数据，如果确认要备份新数据,请在一分钟之内再次运行此命令
    exit
    fi
  ## no backup
  elif [ -e /dev/block/mmcblk0p2 ]
  then
  busybox rm -rf /sd-ext/data
  busybox cp -rp /data/data /sd-ext/
  busybox rm -rf /sd-ext/system
  busybox cp -rp /data/system /sd-ext/
  busybox rm -rf /sd-ext/wifi
  busybox cp -rp /data/misc/wifi /sd-ext/
  nowdate=`busybox date +%F-%H-%M-%S`
  busybox rm -f /sd-ext/*.backup
  busybox touch /sd-ext/$nowdate.backup
  echo `busybox date +%F" "%T` Backup all DATA to sd-ext... >> /system/log.txt
  echo "Geno：数据及设置已经备份到sd-ext"
  exit
  fi
# MODE TWO Backup data to sdcard
elif [ $BACKUPMODE = 1 ]
then
  ## backup all data
  if [ -e /system/etc/backuping ]
  then
  busybox mkdir /sdcard/Gbackup
  busybox rm -f /sdcard/Gbackup/system.tar
  busybox rm -f /sdcard/Gbackup/data.tar
  busybox rm -f /sdcard/Gbackup/wifi.tar
  busybox tar -cpf /sdcard/Gbackup/system.tar /data/system
  busybox tar -cpf /sdcard/Gbackup/data.tar /data/data
  busybox tar -cpf /sdcard/Gbackup/wifi.tar /data/misc/wifi
  nowdate=`busybox date +%F-%H-%M-%S`
  busybox rm -f /sdcard/Gbackup/*.backup
  busybox touch /sdcard/Gbackup/$nowdate.backup
  busybox rm -f /system/etc/backuping
  echo `busybox date +%F" "%T` Backup all DATA to sdcard... >> /system/log.txt
  echo "Geno：数据及设置已经备份到sdcard"
  exit
  ## prepare backup all data
  elif [ -e /sdcard/Gbackup/data.tar -a -e /sdcard/Gbackup/system.tar -a -e  /sdcard/Gbackup/wifi.tar ]
  then
  backupfile=`busybox ls /sdcard/Gbackup/*.backup |busybox cut -d/ -f4`
  backupdate=${backupfile%.backup}
  busybox touch /system/etc/backuping
  start timing
  echo Geno：发现你Sdcard已经存在备份时间为：$backupdate 的数据，如果确认要备份新数据,请在一分钟之内再次运行此命令
  exit
  ## backup all data - no backup
  else
  busybox mkdir /sdcard/Gbackup
  busybox rm -f /sdcard/Gbackup/system.tar
  busybox rm -f /sdcard/Gbackup/data.tar
  busybox rm -f /sdcard/Gbackup/wifi.tar
  busybox tar -cpf /sdcard/Gbackup/system.tar /data/system
  busybox tar -cpf /sdcard/Gbackup/data.tar /data/data
  busybox tar -cpf /sdcard/Gbackup/wifi.tar /data/misc/wifi
  nowdate=`busybox date +%F-%H-%M-%S`
  busybox rm -f /sdcard/Gbackup/*.backup
  busybox touch /sdcard/Gbackup/$nowdate.backup
  echo `busybox date +%F" "%T` Backup all DATA to sdcard... >> /system/log.txt
  echo "Geno：数据及设置已经备份到sdcard"
  exit
  fi
# MODE THREE Backup all to sdcard
elif [ $BACKUPMODE = 2 ]
then
  ## backup app and data
  if [ -e /system/etc/backuping ]
  then
  busybox mkdir /sdcard/Gbackup
  busybox rm -f /sdcard/Gbackup/system.tar
  busybox rm -f /sdcard/Gbackup/data.tar
  busybox rm -f /sdcard/Gbackup/wifi.tar
  busybox rm -f /sdcard/Gbackup/app.tar
  busybox tar -cpf /sdcard/Gbackup/system.tar /data/system
  busybox tar -cpf /sdcard/Gbackup/data.tar /data/data
  busybox tar -cpf /sdcard/Gbackup/wifi.tar /data/misc/wifi
  busybox tar -chpf /sdcard/Gbackup/app.tar /data/app
  nowdate=`busybox date +%F-%H-%M-%S`
  busybox rm -f /sdcard/Gbackup/*.backup
  busybox touch /sdcard/Gbackup/$nowdate.backup
  busybox rm -f /system/etc/backuping
  echo `busybox date +%F" "%T` Backup APP and DATA to sdcard... >> /system/log.txt
  echo "Geno：程序、数据及设置已经备份到sdcard"
  exit
  ## prepare backup app and data
  elif [ -e /sdcard/Gbackup/data.tar -a -e /sdcard/Gbackup/system.tar -a -e  /sdcard/Gbackup/wifi.tar -a -e /sdcard/Gbackup/app.tar ]
  then
  backupfile=`busybox ls /sdcard/Gbackup/*.backup |busybox cut -d/ -f4`
  backupdate=${backupfile%.backup}
  busybox touch /system/etc/backuping
  start timing
  echo Geno：发现你Sdcard已经存在备份时间为：$backupdate 的程序和数据，如果确认要备份新程序和数据,请在一分钟之内再次运行此命令
  exit
  ## backup app and data
  else
  busybox mkdir /sdcard/Gbackup
  busybox rm -f /sdcard/Gbackup/system.tar
  busybox rm -f /sdcard/Gbackup/data.tar
  busybox rm -f /sdcard/Gbackup/wifi.tar
  busybox rm -f /sdcard/Gbackup/app.tar
  busybox tar -cpf /sdcard/Gbackup/system.tar /data/system
  busybox tar -cpf /sdcard/Gbackup/data.tar /data/data
  busybox tar -cpf /sdcard/Gbackup/wifi.tar /data/misc/wifi
  busybox tar -chpf /sdcard/Gbackup/app.tar /data/app
  nowdate=`busybox date +%F-%H-%M-%S`
  busybox rm -f /sdcard/Gbackup/*.backup
  busybox touch /sdcard/Gbackup/$nowdate.backup
  echo `busybox date +%F" "%T` Backup APP and DATA to sdcard... >> /system/log.txt
  echo "Geno：程序、数据及设置已经备份到sdcard"
  exit
  fi
fi
exit
