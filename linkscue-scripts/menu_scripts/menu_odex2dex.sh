#!/bin/bash

#self
script_self=$(readlink -f $0)

#顶级目录变量
TOPDIR=${script_self%/linkscue-scripts/menu_scripts/menu_odex2dex.sh}
scripts_dir=$TOPDIR/linkscue-scripts
sub_menu_dir=$scripts_dir/menu_scripts
zipalign=$TOPDIR/linkscue-scripts/zipalign

#脚本自身相关变量
wd=$1
oldwd=$(pwd)
odex2dex=$scripts_dir/odex2dex/odex2dex.sh

#创建目录
mkdir -p $wd/odex_apk &> /dev/null
mkdir -p $wd/framework &> /dev/null
mkdir -p $wd/apk_new &> /dev/null

#初始化
clear
echo "
欢迎使用linkscue 合并odex和apk定制厨房工具！"
echo "
操作说明：

1. 把需要合并odex和apk的文件放置于工作目录$(basename $wd)/odex_apk/; 

2. 把手机的/system/framework/全部文件拷贝至工作目录$(basename $wd)/framework/;
"
read -p "以下操作完成后，按任意键以继续:"

#错误侦测
while [[ $(ls -1 $wd/framework/) == "" ]]; do
    echo ""
    read -p "请把/system/framework/全部文件拷贝至工作目录$(basename $wd)/framework/:" 
done
while [[ $(ls -1 $wd/odex_apk/) == "" ]]; do
    echo ""
    read -p "请把需要合并odex和apk的文件拷贝至工作目录$(basename $wd)/odex_apk/:" 
done

#获取apk文件列表；
ls -1 $wd/odex_apk/*.apk | sed 's/\.apk//g' > $wd/odexed_apklist.txt

#逐个取出应用程序并进行odex2dex,工作目录必须是framework下；
echo "
I: 正在进行合并操作 .."
cd $wd/framework
cat $wd/odexed_apklist.txt | while read line;do
    cp $line.apk .
    cp $line.odex .
    if [[ -f $line.apk ]] && [[ $line.odex ]]; then
        $odex2dex $line.apk $line.odex
    fi
    cp $(basename $line.apk) ../apk_new/
    rm -f $(basename $line).apk 
    rm -f $(basename $line).odex 
done
cd $oldwd

echo "
合并操作已完成，输出文件在$(basename $wd)/apk_new/"

#返回主菜单界面
echo ""
read -p "请按任意键返回主菜单:"
$TOPDIR/scue_kitchen.sh
