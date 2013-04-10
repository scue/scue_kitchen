#!/system/bin/sh 
#===============================================================================
#
#          FILE: restore_rom.sh
# 
#         USAGE: restore_rom.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: linkscue (scue), linkscue@gmail.com
#       CREATED: 2013年04月07日 18时57分26秒 HKT
#     COPYRIGHT: Copyright (c) 2013, linkscue
#      REVISION: 0.1
#  ORGANIZATION: ATX风雅组
#===============================================================================

# 可添加任意一个分区
# 如华为定制的cust分区
# 如联想K860系列的preload分区
# 如联想S2系列的apppackages分区
# 会自动判断这些分区是否存在，故多多益善
part_array_tar="cache system data preload cust apppackages"

rom=ROM.zip                                     # rom name
zip=/data/local/tmp/zip                         # zip cmd
zip_cmd="$zip -r $rom META-INF/ mount_data.sh restore_rom.sh"
clear_cmd="rm -r META-INF/ mount_data.sh restore_rom.sh"

#数据存放位置，默认是内置sd卡(速度快)
restore_pos=/sdcard

#wd
cd /

#tar
for part_tar in $part_array_tar; do
    if [[ -d $part_tar ]]; then                 # 只有在分区对应的目录存在时才tar"备份"
        zip_cmd="$zip_cmd $part_tar.tar.bz2"
        clear_cmd="$clear_cmd $part_tar.tar.bz2"
        part_pos=$restore_pos/$part_tar.tar.bz2
        /data/local/tmp/busybox echo 
        /data/local/tmp/busybox echo "<<< 正在备份$part_tar分区"
        /data/local/tmp/busybox tar jcvf $part_pos $part_tar 
        /data/local/tmp/busybox echo ">>> 成功备份$part_tar分区"
    fi
done

cd $restore_pos                                 # work directory
/data/local/tmp/busybox rm -r META-INF/ 2>/dev/null						# rm directory
/data/local/tmp/busybox cp /data/local/tmp/META-INF $restore_pos/META-INF -af 2> /dev/null
/data/local/tmp/busybox cp /data/local/tmp/mount_data.sh $restore_pos/mount_data.sh
/data/local/tmp/busybox cp /data/local/tmp/restore_rom.sh $restore_pos/restore_rom.sh
/data/local/tmp/busybox echo
/data/local/tmp/busybox echo "<<< 正在制作zip卡刷包$rom"
/data/local/tmp/busybox mv $rom ${rom}_bak 2> /dev/null
$zip_cmd                                        # compress the files
$clear_cmd                                      # clear the files for free spaces
/data/local/tmp/busybox echo ">>> 成功制作zip卡刷包$rom"
/data/local/tmp/busybox echo 
/data/local/tmp/busybox echo "注：可以自行添加misc.img boot.img recovery.img至$rom当中(无须修改升级脚本)"
