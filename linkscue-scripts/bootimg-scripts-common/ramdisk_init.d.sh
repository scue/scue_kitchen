#!/bin/bash

ramdisk_dir=$(find . -type d | sed -n '2p')
init_file=$ramdisk_dir/init.rc
init_d_cmd=../linkscue-scripts/bootimg-scripts-common/init.d_cmd.txt

start_line=$(sed -n '$=' $init_file)
detect=$(cat bootimg.log | grep "init.d")
if [[ $detect == "" ]]; then
    sed -i "$start_line r $init_d_cmd" $init_file
fi
