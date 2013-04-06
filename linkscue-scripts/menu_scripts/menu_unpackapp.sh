#!/bin/bash

#self
script_self=$(readlink -f $0)

#dir
TOPDIR=${script_self%/linkscue-scripts/menu_scripts/menu_unpackapp.sh}
scripts_dir=$TOPDIR/linkscue-scripts
sub_menu_dir=$scripts_dir/menu_scripts
zipalign=$TOPDIR/linkscue-scripts/zipalign

wd=$1
oldwd=$(pwd)
unpackhwapp=$scripts_dir/huawei_unpack_official_rom/unpackhwapp_x86
#init
clear
echo "
欢迎使用linkscue 解压UPDATE.APP定制厨房工具！"
echo "
把将要解压的UPDATE.APP文件放置于$(basename $wd)目录下; "
while [[ ! -f $wd/UPDATE.APP ]];do
echo ""
read -p "请把UPDATE.APP文件放置于于$(basename $wd)目录下:"
done

cd $wd
echo "
I:正在进行解压(内存不够将会比较卡)..
"
echo "I:正在执行解压.."
$unpackhwapp UPDATE.APP
mkdir -p $wd/output &> /dev/null
mv -f $wd/*.img $wd/output/
cd $oldwd

echo "
解压完毕，解压文件放置于$(basename $wd)/output/
"
echo ""
read -p "请按任意键返回主菜单:"
$TOPDIR/scue_kitchen.sh
