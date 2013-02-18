#!/sbin/sh
#version:0.4
#author:linkscue@gmail.com
#实现功能:自定义data分区大小的卡刷包；
#相关说明:仅对相近于华为u8825d起效，荣耀2是海思平台不可使用；

#请自定义data分区的大小（单位G）；
size=2.3

#打开外置sd卡，用于保存日志，方便出错时分析；
sd_ext=`cat /etc/recovery.fstab | sed -n '/mmcblk1p1/p'| sed "/^#/d" | awk '{print $1}'`
/sbin/mount $sd_ext
echo "--- repart huawei device's rom log ---" > $sd_ext/repart_huawei.log

#控制非相近于U8825d的机型，避免误刷导致“返厂”；
detect_data=`cat /etc/recovery.fstab | grep mmcblk0p18 | grep data | sed '/^#/d'`
detect_sdin=`cat /etc/recovery.fstab | grep mmcblk0p19 | grep vfat | sed '/^#/d'`
if [[ "$detect_data" = "" ]] || [[ "$detect_sdin" = "" ]]; then
    echo "E:/dev/block/mmcblk0 not like huawei u8825d device's!" >> $sd_ext/repart_huawei.log
    exit 99
fi

#获取手机内存大小、磁柱数量及计算每磁柱含字节数；
btotal=$(fdisk -l /dev/block/mmcblk0 | sed -n '/Disk/{/bytes/p}' | awk -F',' '{print $2}' | awk '{print $1}')
ctotal=$(fdisk -l /dev/block/mmcblk0 | sed -n '/heads/{/cylinders/p}' | awk -F',' '{print $3}' | awk '{print $1}')
bpc=`awk "BEGIN{print $btotal/$ctotal}"`
echo $btotal 

#计算data分区字节数、磁柱数，以及data、内置sd卡起始和终止磁柱；
bsize=`awk "BEGIN{print $size*1024*1024*1024}"`
csize=`awk "BEGIN{print $bsize/$bpc}"`
start18=$((`fdisk -l /dev/block/mmcblk0 | sed -n '/mmcblk0p17/p' | awk '{print $3}'`+2))
start19=$(($start18 + $csize + 2))
end18=$(($start18 + $csize))
end19=$ctotal

#计算data分区的最大值(单位G),并判断分区大小是否有误；
max=`awk "BEGIN{print ($ctotal-$start18)*$bpc/(1024*1024*1024)}"`
out_range=`awk "BEGIN{print $max-$size}" | sed -n '/\-/p'`
echo "I:max size of data part is ${max}g" >> $sd_ext/repart_huawei.log
if [[ "$out_range" != "" ]];then
	echo "E:/dev/block/mmcblk0p18's size is ${size}g, out of range!" >> $sd_ext/repart_huawei.log
	exit 1
fi

#输出data、内置sd卡分区大小信息到分区日志；
size_data=$size
size_sdin=`awk "BEGIN{print $max-$size_data}"`
echo "I:/dev/block/mmcblk0p18 start $start18 end $end18, size=${size_data}g" >> $sd_ext/repart_huawei.log
echo "I:/dev/block/mmcblk0p19 start $start19 end $end19, szie=${size_sdin}g" >> $sd_ext/repart_huawei.log

#分区操作前，要把/dev/block/mmcblk0所有已挂载的分区卸载；
for dev in `/sbin/mount | /sbin/grep mmcblk0 | /sbin/awk '{print $1}'`;do 
    echo "I:umount $dev .." >> $sd_ext/repart_huawei.log
    /sbin/umount $dev >> $sd_ext/repart_huawei.log
done

#
#检测是否已经卸载成功，卸载失败则退出程序，避免错误的分区导致手机返厂；
#had_mount=`/sbin/mount | /sbin/grep mmcblk0 | /sbin/awk '{print $1}'`
#if [[ "$had_mount" != "" ]]; then
#    echo "E:can't umount $had_mount!" >> $sd_ext/repart_huawei.log
#    exit 2
#fi
#由linkscue于2013-02-10删除此段脚本，以提升不同recovery刷入成功率；
#

#把计算所得的分区信息写入分区表，和格式化data、内置sd卡分区；
fdisk /dev/block/mmcblk0 << EOF 
d
19
d
18
n
$start18
$end18
n
$start19
$end19
t
19
b
p
w
EOF
echo "I: format /dev/block/mmcblk0p18 .." >> $sd_ext/repart_huawei.log
/sbin/mke2fs -T ext4 /dev/block/mmcblk0p18 | tee -a $sd_ext/repart_huawei.log
echo "I: format /dev/block/mmcblk0p19 .." >> $sd_ext/repart_huawei.log
/sbin/busybox mkdosfs -v -n huawei /dev/block/mmcblk0p19 | tee -a $sd_ext/repart_huawei.log
echo "I: 分区已成功，新的分区表内容如下：" >> $sd_ext/repart_huawei.log
fdisk -l /dev/block/mmcblk0 | sed '/^$/d' >> $sd_ext/repart_huawei.log
echo "I: 如果把data分区改小，最好双清一下以解决可能存在的无限重启问题。" >> $sd_ext/repart_huawei.log

#检测内置sd卡是否已成功格式化，能否成功挂载，若不能则再次格式化；
sd_int=`cat /etc/recovery.fstab | grep mmcblk0p19 | sed "/^#/d" | awk '{print $1}'`
while [[ `/sbin/mount $sd_int;echo $?` != 0 ]]; do
    /sbin/busybox mkdosfs -v -n huawei /dev/block/mmcblk0p19 | tee -a $sd_ext/repart_huawei.log
    /sbin/umount $sd_int
done

#所有操作已经完成，日志文件在外置sd卡上的repart_huawei.log,恭喜！
echo "I: All done, enjoy!Linkscue祝您新春快乐，蛇年吉祥！" >> $sd_ext/repart_huawei.log
echo "I: at `date +%F` `date +%X`" >> $sd_ext/repart_huawei.log
echo "I: Supported by linkscue@gmail.com " >> $sd_ext/repart_huawei.log
echo "--- repart huawei device's rom log ---" >> $sd_ext/repart_huawei.log
