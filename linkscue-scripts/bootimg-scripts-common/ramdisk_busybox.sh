#!/bin/bash

#self
script_self=$(readlink -f $0)
dir_self=$(dirname $script_self)

ramdisk_dir=$(find . -type d | sed -n '2p')
init_file=$ramdisk_dir/init.rc
busybox_cmd=$dir_self/busybox_cmd.txt
busybox_file=$dir_self/busybox
tmp=tmp_$$.txt

start_line=$(sed -n '/symlink/{/vendor/=}' $init_file)
sed "/busybox/d" $init_file | tee $tmp
sed -i "$start_line r $busybox_cmd" $tmp 
cp $tmp $init_file
cp $busybox_file $ramdisk_dir/sbin/busybox
rm $tmp
