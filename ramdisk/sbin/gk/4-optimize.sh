#!/system/bin/sh
# By Genokolar 2011/02/07
if [ -d /system/etc/optimize-run ]
then
busybox rm -rf /system/etc/optimize-run
busybox touch /system/etc/delodex
start timing
echo "Geno：已经关闭优化功能，一分钟后会自动删除odex文件并重启手机"
echo "如果你是要手动优化，请在一分钟内再运行此命令一次以避免重启手机"
else
busybox mkdir /system/etc/optimize-run
start optimize
echo `busybox date +%F" "%T` Optimize system apk... >> /system/log.txt
echo "Geno：已经开启优化功能，程序随后会自动优化，如果优化后出现程序无法开启，请重启一次手机"
fi
exit
