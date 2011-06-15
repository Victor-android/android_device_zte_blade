#!/system/bin/sh
# By Genokolar 2011/02/07

# read conf
if [ -e /system/etc/enhanced.conf ]
then
SWAPSIZE=`busybox grep SWAPSIZE /system/etc/enhanced.conf |busybox cut -d= -f2 `
SWAPADD=`busybox grep SWAPADD /system/etc/enhanced.conf |busybox cut -d= -f2 `
SWAPPINESS=`busybox grep SWAPPINESS /system/etc/enhanced.conf |busybox cut -d= -f2 `
SDEXT=`busybox grep SDEXT /system/etc/enhanced.conf |busybox cut -d= -f2 `
SDSWAP=`busybox grep SDSWAP /system/etc/enhanced.conf |busybox cut -d= -f2 `
else
SWAPSIZE="64"
SWAPADD="/sd-ext"
SWAPPINESS="35"
SDEXT="mmcblk0p2"
SDSWAP="mmcblk0p3"
fi

# MOUNT SD-EXT
if [ -e /dev/block/$SDEXT -a -e /system/etc/.nomount ]
then
mount -t ext4 /dev/block/$SDEXT /sd-ext
if [ -s /sd-ext ]
then
busybox rm -f /system/etc/.nomount
echo Mount SD-ext... >> /system/log.txt
echo 已开启SD-EXT分区和增强功能，再运行此命令即可使用增强功能
exit
fi
fi


# swap on
if cat /proc/meminfo|busybox grep "SwapTotal"|busybox grep -q " 0 kB"
then
  if [ -e /dev/block/$SDSWAP ]
  then
  busybox swapon /dev/block/$SDSWAP
    if ! cat /proc/meminfo|busybox grep "SwapTotal"|busybox grep -q " 0 kB"
    then
      busybox mkdir /system/etc/swap-run
      echo `busybox date +%F" "%T` Open SWAP with partition... >> /system/log.txt
      echo "Geno：使用swap分区开启了SWAP功能"
    else
      echo "Geno：开启SWAP功能失败，请检查enhanced.conf是否设定正确，SWAP分区是否正确分区、挂载等"
    fi
  else
    if [ -e $SWAPADD/swap.file ]
    then
    busybox mkswap $SWAPADD/swap.file 1>/dev/null
    busybox swapon $SWAPADD/swap.file 1>/dev/null
    busybox sysctl -w vm.swappiness=$SWAPPINESS
      if ! cat /proc/meminfo|busybox grep "SwapTotal"|busybox grep -q " 0 kB"
      then
        busybox mkdir /system/etc/swap-run
        echo `busybox date +%F" "%T` Open SWAP with $SWAPADD/swap.file... >> /system/log.txt
        echo Geno：使用swap文件$SWAPADD/swap.file开启了SWAP功能，SWAP优先率为：$SWAPPINESS，请检查是否开启成功
      else
        echo "Geno：开启SWAP功能失败，请检查enhanced.conf是否设定正确，SDEXT分区是否挂载成功等"
      fi
    else
    # sd-ext is mount
      if [ -s $SWAPADD ]
      then
      dd if=/dev/zero of=$SWAPADD/swap.file bs=1048576 count=$SWAPSIZE
      busybox mkswap $SWAPADD/swap.file 1>/dev/null
      busybox swapon $SWAPADD/swap.file 1>/dev/null
      busybox sysctl -w vm.swappiness=$SWAPPINESS
      else
      echo SD-EXT分区没有正确挂载，请先正确挂载SD-EXT分区
      fi
      if ! cat /proc/meminfo|busybox grep "SwapTotal"|busybox grep -q " 0 kB"
      then
        busybox mkdir /system/etc/swap-run
        echo `busybox date +%F" "%T` Open SWAP with new creat $SWAPADD/swap.file... >> /system/log.txt
        echo Geno：建立了swap文件$SWAPADD/swap.file，SWAP优先率为：$SWAPPINESS，并且开启SWAP功能，请检查是否开启成功
      else
        echo "Geno：开启SWAP功能失败，请检查enhanced.conf是否设定正确，SDEXT分区是否挂载成功等"
      fi
    fi
  fi

# swap off
elif ! cat /proc/meminfo|busybox grep "SwapTotal"|busybox grep -q " 0 kB"
then
  if [ -e /dev/block/$SDSWAP ]
  then
  busybox swapoff /dev/block/$SDSWAP
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
