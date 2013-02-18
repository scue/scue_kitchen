#!/bin/bash
#version:0.1
#author:linkscue@gmail.com
#使用方法：./fixuisize.sh SystemUI.apk
#实现功能：用于修正从网上的厨房制作的百分电量图标太大的问题；

#错误侦测
if [[ $# != 1 ]]; then
    echo "usage:`basename $0` [SystemUI.apk]"
    exit 1
fi

#初始化相关变量
apk=$1
DIRNAME=${1%.*}
TOPDIR=`dirname $1`
adbd="adb"

#判断apk文件路径起始位置是否含有有./，若有则去掉它；
if [[ $(echo $1 | grep '^\./') != "" ]]; then
    apk=`echo $1 | grep '\./' | sed -n 's/^..//p'`
    echo $apk
fi

#判断apk文件是不是绝对路径，若不是绝对路径，则强制添加上去；
if [[ $(echo $apk | grep `pwd`) == "" ]]; then
    apk=`pwd`/$apk
    DIRNAME=${apk%.*}
    TOPDIR=`dirname $DIRNAME`
fi

#百分比电量放置的位置
battery_dir=$DIRNAME/res/drawable-hdpi

#进行更换图标大小的操作
rm -rf $DIRNAME &> /dev/null
unzip $apk -d $DIRNAME &> /dev/null
find $battery_dir -name 'stat_sys_battery_?.png' -exec convert -resize 30x30 {} {} \;
find $battery_dir -name 'stat_sys_battery_??.png' -exec convert -resize 30x30 {} {} \;
find $battery_dir -name 'stat_sys_battery_???.png' -exec convert -resize 30x30 {} {} \;
find $battery_dir -name 'stat_sys_battery_charge_anim*.png' -exec convert -resize 30x30 {} {} \;
find $battery_dir -name 'stat_sys_battery_unknown.png' -exec convert -resize 30x30 {} {} \;
cd $DIRNAME/
zip -r $TOPDIR/SystemUI_1p_30_battery.apk * &> /dev/null
cd $TOPDIR
zipalign -v 4 $TOPDIR/SystemUI_1p_30_battery.apk $TOPDIR/SystemUI_1p_30_battery_aligned.apk &> /dev/null

#开始刷入手机内
$adbd wait-for-device
$adbd remount
$adbd push $TOPDIR/SystemUI_1p_30_battery_aligned.apk /system/app/SystemUI.apk
$adbd shell chmod 775 /system/app/SystemUI.apk
$adbd shell reboot
