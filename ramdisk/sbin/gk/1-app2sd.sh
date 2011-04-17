#!/system/bin/sh
# By Genokolar 2011/02/07

# MOUNT SD-EXT
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
# app2sd first
if [ ! -d /etc/app2sd-run -a ! -d /etc/app2sd-off -a ! -d /etc/app2sd-false -a ! -d /etc/app2sd-retry ]
then
  if [ -e /dev/block/mmcblk0p2 ]
  then
    ## if exist app
    if [ -d /sd-ext/app ]
    then
      ### prepare do
      if [ ! -e /sd-ext/app/.first ]
      then
      busybox touch /sd-ext/app/.first
      start timing
      echo "Geno：发现你EXT分区已经存在app程序目录，如果只使用新程序，请删除sd-ext目录下app程序目录后再运行此命令一次；如果要使用EXT卡上的程序，请在一分钟内再运行此命令一次"
      exit
      ### do
      else
      busybox rm -f /sd-ext/app/.first
      busybox cp -rp /data/app /sd-ext
      echo `busybox date +%F" "%T` Open APP2SD with old app2sd... >> /system/log.txt
      busybox mkdir /system/etc/app2sd-on
      fi
    ## no app
    else
    busybox cp -rp /data/app /sd-ext
    echo `busybox date +%F" "%T` Open APP2SD with copy new... >> /system/log.txt
    busybox mkdir /system/etc/app2sd-on
    fi
  sync
  reboot
  fi
fi


# app2sd off
if [ -d /etc/app2sd-run ]
then 
  if [ -d /sd-ext/app ]
  then
  baksize=`busybox du -sm /sd-ext/app |busybox cut -f1`
  datadir=`busybox du -sm /data |busybox cut -f1`
  datasize=$((178-datadir))
    if [ $baksize -lt $datasize ]
    then
    busybox cp -rp /sd-ext/app /data/appbak
    echo `busybox date +%F" "%T` Close APP2SD... >> /system/log.txt
    busybox mv /system/etc/app2sd-run /system/etc/app2sd-off
    sync
    reboot
    else
    echo "APP2SD占用空间约为 $baksize M ,手机内部存储空间现可用为 $datasize M ，不足以关闭APP2SD，请删除部分程序后再重试关闭APP2SD"
    fi
  fi
fi


# app2sd retry
if [ -d /etc/app2sd-false ]
then 
  if [ -e /dev/block/mmcblk0p2 ]
  then
  echo `busybox date +%F" "%T` Retry APP2SD... >> /system/log.txt
  busybox mv /system/etc/app2sd-false /system/etc/app2sd-retry
  sync
  reboot
  fi
fi

exit
