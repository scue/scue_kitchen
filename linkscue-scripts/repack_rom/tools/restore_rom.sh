#!/sbin/sh
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
#       CREATED: 2013年04月07日 21时01分13秒 HKT
#     COPYRIGHT: Copyright (c) 2013, linkscue
#      REVISION: 0.1
#  ORGANIZATION: ATX风雅组
#===============================================================================

log_file=/sdcard/scue_restore.log
echo -n "" > $log_file # clear

if [[ -f /etc/recovery.fstab ]]; then
    dev_misc=$(cat /etc/recovery.fstab | sed '/^#/d' | awk '/misc/ {print $3}')
    dev_boot=$(cat /etc/recovery.fstab | sed '/^#/d' | awk '/boot/ {print $3}')
    dev_recovery=$(cat /etc/recovery.fstab | sed '/^#/d' | awk '/recovery/ {print $3}')
    dev_cache=$(cat /etc/recovery.fstab | sed '/^#/d' | awk '/cache/ {print $3}')
    dev_cust=$(cat /etc/recovery.fstab | sed '/^#/d' | awk '/cust/ {print $3}')
    dev_system=$(cat /etc/recovery.fstab | sed '/^#/d' | awk '/system/ {print $3}')
    dev_data=$(cat /etc/recovery.fstab | sed '/^#/d' | awk '/data/ {print $3}')
else
    echo "can't find /etc/recovery.fstab!" >> $log_file
fi


part_array_dd="misc boot recovery"
part_array_tar="cache cust system data"

#在recovery模式下，数据存放位置，默认是data空间(往往这个空间比较大)
restore_pos=/data

#wd
cd /

#tar
for part_tar in $part_array_tar; do
    eval part_dev=\$dev_$part_tar
    part_pos=$restore_pos/$part_tar.tar.bz2
    mount -o rw $part_dev /$part_tar 2> /dev/null 
    echo  >> $log_file
    echo "mount -o rw $part_dev /$part_tar" >> $log_file
    if [[ -f $part_pos ]]; then 
        if [[ "$part_tar" != "data" ]]; then
            rm -r /$part_tar/*
        fi
        echo "<<< 正在刷入$part_tar分区" >> $log_file
        tar jxvf $part_pos  2>&1 >> $log_file
        echo ">>> 成功刷入$part_tar分区" >> $log_file
        rm $part_pos 2> /dev/null  # 及时删除以避免浪费空间       
        echo "rm $part_pos" >> $log_file
    else
        echo ">>> 不存在$part_pos，不刷入至$part_dev"  >> $log_file
    fi
done

#dd
for part_dd in $part_array_dd; do
    eval part_dev=\$dev_$part_dd
    part_pos=$restore_pos/$part_dd.img
    if [[ "$part_dev" == "" ]]; then
        echo >> $log_file
        echo ">>> 无法找到$part_dd所在分区，不刷入$part_dd分区" >> $log_file
        continue
    fi
    echo >> $log_file
    if [[ -f $part_pos ]]; then
        echo "<<< 正在刷入$part_dd" >> $log_file
        dd if=$part_pos of=$part_dev 2>> $log_file
        echo ">>> 成功刷入$part_dev" >> $log_file
        rm $part_pos 2> /dev/null  # 及时删除以避免浪费空间       
        echo "rm $part_pos" >> $log_file
    else
        echo ">>> 不存在$part_pos，不刷入至$part_dev" >> $log_file 
    fi
done
