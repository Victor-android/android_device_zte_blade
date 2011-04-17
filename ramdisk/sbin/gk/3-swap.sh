#!/system/bin/sh
# By Genokolar 2011/02/07

# read conf
if [ -e /system/etc/enhanced.conf ]
then
SWAPSIZE=`busybox grep SWAPSIZE /system/etc/enhanced.conf |busybox cut -d= -f2 `
SWAPADD=`busybox grep SWAPADD /system/etc/enhanced.conf |busybox cut -d= -f2 `
SWAPPINESS=`busybox grep SWAPPINESS /system/etc/enhanced.conf |busybox cut -d= -f2 `
else
SWAPSIZE="64"
SWAPADD="/sd-ext"
SWAPPINESS="35"
fi

# MOUNT SD-EXT
if [ -e /dev/block/mmcblk0p2 -a -e /system/etc/.nomount -a ! -e /dev/block/mmcblk0p3 ]
then
if [ $SWAPADD = "/sd-ext" ]
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
fi

# swap on
if [ ! -d /etc/swap-run ]
then
  if [ -e /dev/block/mmcblk0p3 ]
  then
  busybox swapon /dev/block/mmcblk0p3
  busybox mkdir /system/etc/swap-run
  echo `busybox date +%F" "%T` Open SWAP with partition... >> /system/log.txt
  echo "Geno：使用swap分区开启了SWAP功能，请检查是否开启成功"
  else
    if [ -e $SWAPADD/swap.file ]
    then
    busybox mkswap $SWAPADD/swap.file 1>/dev/null
    busybox swapon $SWAPADD/swap.file 1>/dev/null
    busybox sysctl -w vm.swappiness=$SWAPPINESS
    busybox mkdir /system/etc/swap-run
    echo `busybox date +%F" "%T` Open SWAP with $SWAPADD/swap.file... >> /system/log.txt
    echo Geno：使用swap文件$SWAPADD/swap.file开启了SWAP功能，SWAP优先率为：$SWAPPINESS，请检查是否开启成功
    else
    dd if=/dev/zero of=$SWAPADD/swap.file bs=1048576 count=$SWAPSIZE
    busybox mkswap $SWAPADD/swap.file 1>/dev/null
    busybox swapon $SWAPADD/swap.file 1>/dev/null
    busybox sysctl -w vm.swappiness=$SWAPPINESS
    busybox mkdir /system/etc/swap-run
    echo `busybox date +%F" "%T` Open SWAP with new creat $SWAPADD/swap.file... >> /system/log.txt
    echo Geno：建立了swap文件$SWAPADD/swap.file，SWAP优先率为：$SWAPPINESS，并且开启SWAP功能，请检查是否开启成功
    fi
  fi

# swap off
elif [ -e /system/etc/closeswap ]
then
  if [ -e /dev/block/mmcblk0p3 ]
  then
  busybox swapoff /dev/block/mmcblk0p3
  busybox rm -rf /system/etc/swap-run
  echo `busybox date +%F" "%T` Close SWAP with partition... >> /system/log.txt
  echo "Geno：SWAP关闭，请检查是否关闭成功"
  elif [ -e $SWAPADD/swap.file ]
  then
  busybox swapoff $SWAPADD/swap.file
  busybox rm -rf /system/etc/swap-run
  echo `busybox date +%F" "%T` Close SWAP with $SWAPADD/swap.file... >> /system/log.txt
  echo Geno：SWAP关闭，请检查是否关闭成功，如果你短时间内不再开启SWAP功能，你可以删除$SWAPADD/swap.file文件，但是下次开启会花15秒左右的时间重新建立此文件。
  fi
else
  busybox touch /system/etc/closeswap
  start timing
  echo Geno：你开启了SWAP功能，如果确认要关闭SWAP功能,请在一分钟之内再次运行此命令
  exit
fi

exit
