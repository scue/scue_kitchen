#!/bin/bash
#self
script_self=$(readlink -f $0)
dir_self=$(dirname $script_self)

ramdisk_dir=$(find . -type d | sed -n '2p')
init_file=$ramdisk_dir/init.rc
init_d_cmd=$dir_self/init.d_cmd.txt

start_line=$(sed -n '$=' $init_file)
detect=$(cat bootimg.log | grep "init.d")
if [[ $detect == "" ]]; then
    sed -i "$start_line r $init_d_cmd" $init_file
fi
