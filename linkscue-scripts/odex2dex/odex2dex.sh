#!/bin/bash

#顶级目录变量
TOPDIR=../..
scripts_dir=$TOPDIR/linkscue-scripts
sub_menu_dir=$scripts_dir/menu_scripts
zipalign=$TOPDIR/linkscue-scripts/zipalign

#脚本自身变量
apk=$1
odex=$2
apk_dir="$apk"_tmp_$$
odex_dir="$odex"_tmp_$$
dir_self=$(dirname $0)
smali=$dir_self/smali/smali.jar
baksmali=$dir_self/smali/baksmali.jar

#odex2dex
java -jar $baksmali -x $odex -o $odex_dir
java -Xmx512M -jar $smali $odex_dir -o classes.dex

#解压apk文件,操作目录必须是framework目录；
unzip $apk -d $apk_dir > /dev/null
cp classes.dex $apk_dir/classes.dex
cd $apk_dir/
echo "I: 合并$(basename $apk)和$(basename $odex) --> $(basename $apk) .."
zip -r 1.apk ./* > /dev/null
../$zipalign -vf 4 1.apk ../$(basename $apk) &> /dev/null
cd ../

#清理旧的文件；
rm -rf $odex_dir &> /dev/null
rm -rf $apk_dir &> /dev/null
rm -rf classes.dex &> /dev/null

