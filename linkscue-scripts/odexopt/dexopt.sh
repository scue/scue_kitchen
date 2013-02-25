#!/bin/bash

#自身脚本位置
script_self=$(readlink -f $0)
dir_self=$(dirname $script_self)

#顶级目录
TOPDIR=${script_self%/linkscue-scripts/odexopt/dexopt.sh}
scripts_dir=$TOPDIR/linkscue-scripts
sub_menu_dir=$scripts_dir/menu_scripts
dexopt_file=$dir_self/dexopt-wrapper

#手机上的tmp目录
tmp="/data/local/tmp"
opt="/data/local/tmp/dexopt-wrapper"

#指定设备
adbs="adb -s $1"

#apk或jar的来源目录
file_dir=$2
file_list=$(ls -1 $2/*)

#apk或jar的odex输出目录
odex_dir=$3

#获取手机上ROOT权限及tmp目录权限
$adbs shell su -c ls &> /dev/null
$adbs shell su -c mkdir -p /data/local/tmp 2> /dev/null
$adbs shell su -c chmod -R 777 /data/local/tmp/ &> /dev/null

#把必备的文件上传到手机
printf "\n正在上传odex化工具..\n"
$adbs push $dexopt_file $opt
$adbs shell su -c chmod 777 $opt

#开始逐个进行操作；
for file in ${file_list[@]}; do
    printf "\n正在处理$file ..\n"
    file_name=$tmp/$(basename $file)
    file_odex=${file_name%.*}.odex
    $adbs push $file $file_name &> /dev/null
    $adbs shell su -c $opt $file_name $file_odex &> /dev/null
    $adbs pull $file_odex $odex_dir/ &> /dev/null
    $adbs shell su -c rm $file_name
    $adbs shell su -c rm $file_odex
done

#删除odex化工具
$adbs shell su -c rm $opt
