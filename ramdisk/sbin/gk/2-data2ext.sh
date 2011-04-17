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


# data2ext first
if [ ! -d /etc/data2ext-run -a ! -d /etc/data2ext-off -a ! -d /etc/data2ext-false -a ! -d /etc/data2ext-retry ]
then 
  if [ -e /dev/block/mmcblk0p2 ]
  then
    ## if exist data2ext
    if [ -d /sd-ext/data -a -d /sd-ext/system -a ! -e /sd-ext/*.backup ]
    then
      ### prepare do
      if [ ! -e /sd-ext/data/.first ]
      then
      busybox touch /sd-ext/data/.first
      start timing
      echo "Geno：发现你EXT分区已经存在data/system二个目录，如果要使用新数据覆盖EXT卡上的数据，请删除sd-ext目录下的这二个目录，如果要使用EXT卡上的数据，请在一分钟内再运行此命令一次"
      exit
      ### do
      else
      busybox rm -f /sd-ext/data/.first
      echo `busybox date +%F" "%T` Open DATA2EXT with old data2ext... >> /system/log.txt
      busybox mkdir /system/etc/data2ext-on
      fi
    ## if exist backup
    elif [ -d /sd-ext/data -a -d /sd-ext/system -a -d /sd-ext/wifi -a -e /sd-ext/*.backup ]
    then
      ### prepare do
      if [ ! -e /sd-ext/data/.first ]
      then
      backupfile=`busybox ls /sd-ext/*.backup |busybox cut -d/ -f3`
      backupdate=${backupfile%.backup}
      busybox touch /sd-ext/data/.first
      start timing
      echo Geno：发现你EXT分区存在备份时间为：$backupdate 的数据，如果要使用新数据覆盖EXT卡上的数据，请删除sd-ext目录下的data/system/wifi这三个目录及*.backup文件，如果要使用备份数据开启data2ext，请在一分钟内再运行此命令一次
      exit
      ### do
      else
      busybox rm -f /sd-ext/data/.first
      echo `busybox date +%F" "%T` Open DATA2EXT with backup... >> /system/log.txt
      busybox mkdir /system/etc/data2ext-on
      fi
    ## no data
    else
    busybox cp -rp /data/data /sd-ext
    busybox cp -rp /data/system /sd-ext
    echo `busybox date +%F" "%T` Open DATA2EXT with copy new... >> /system/log.txt
    busybox mkdir /system/etc/data2ext-on
    fi
  sync
  reboot
  fi
fi


# data2ext off
if [ -d /etc/data2ext-run ]
then 
  if [ -d /sd-ext/data ]
  then
  baksize=`busybox du -sm /sd-ext/data |busybox cut -f1`
  datadir=`busybox du -sm /data |busybox cut -f1`
  datasize=$((178-datadir))
    if [ $baksize -lt $datasize ]
    then
    busybox cp -rp /sd-ext/data /data/databak
    busybox cp -rp /sd-ext/system /data/systembak
    echo `busybox date +%F" "%T` Close DATA2EXT... >> /system/log.txt
    busybox mv /system/etc/data2ext-run /system/etc/data2ext-off
    sync
    reboot
    else
    echo "Geno：DATA2EXT占用空间约为 $baksize M ,手机内部存储空间现可用为 $datasize M ，不足以关闭DATA2EXT，请删除部分程序后再重试关闭DATA2EXT。"
    fi
  fi
fi


# data2ext retry
if [ -d /etc/data2ext-false ]
then 
  if [ -e /dev/block/mmcblk0p2 ]
  then
  echo `busybox date +%F" "%T` Retry DATA2EXT... >> /system/log.txt
  busybox mv /system/etc/data2ext-false /system/etc/data2ext-retry
  sync
  reboot
  fi
fi

exit
