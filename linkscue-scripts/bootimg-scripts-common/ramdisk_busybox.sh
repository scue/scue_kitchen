#!/bin/bash

ramdisk_dir=$(find . -type d | sed -n '2p')
init_file=$ramdisk_dir/init.rc
busybox_cmd=../linkscue-scripts/bootimg-scripts-common/busybox_cmd.txt
busybox_file=../linkscue-scripts/bootimg-scripts-common/busybox
tmp=tmp_$$.txt

start_line=$(sed -n '/symlink/{/vendor/=}' $init_file)
sed "/busybox/d" $init_file | tee $tmp
sed -i "$start_line r $busybox_cmd" $tmp 
cp $tmp $init_file
cp $busybox_file $ramdisk_dir/sbin/busybox
rm $tmp
