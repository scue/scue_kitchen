#!/sbin/sh
#-------------------------------------------------------------------------------
#  检测手机分区信息
#-------------------------------------------------------------------------------
if [[ -f /etc/recovery.fstab ]]; then
    dev_data=$(cat /etc/recovery.fstab | sed '/^#/d' | awk '/data/ {print $3}')
    mount -o rw $dev_data /data 2> /dev/null
else
    mount -o rw /data 2> /dev/null
fi
rm -r /data/* 2> /dev/null
