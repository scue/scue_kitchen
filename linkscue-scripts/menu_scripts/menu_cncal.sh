#!/bin/bash

#dir
TOPDIR=$(pwd)
scripts_dir=$TOPDIR/linkscue-scripts
sub_menu_dir=$scripts_dir/menu_scripts
zipalign=$TOPDIR/linkscue-scripts/zipalign

#init
clear
echo "
欢迎使用linkscue 农历锁屏定制厨房工具！"

#获取工作目录
undo_cncalender_dir=$1
while [[ ! -f $undo_cncalender_dir/framework.jar ]];do
    echo ""
    read -p "请把framework.jar、android.policy.jar放置于$(basename $undo_cncalender_dir)目录下:"
done
while [[ ! -f $undo_cncalender_dir/android.policy.jar ]];do
    echo ""
    read -p "请把framework.jar、android.policy.jar放置于$(basename $undo_cncalender_dir)目录下:"
done

#一键制作农历锁屏所需工具位置
onekey_cncalender_dir=$TOPDIR/linkscue-scripts/mkcncalender


#侦测运行的必须的java平台
detect_java=$(which java)
if [[ $detect_java == "" ]]; then
    printf "\n糟糕，发现java未安装，请安装java后再尝试。\n"
else
    #开始制作农历锁屏
    printf "\nI:正拷贝必需的文件.."
    mv -f $undo_cncalender_dir/framework.jar $onekey_cncalender_dir/framework.jar
    mv -f $undo_cncalender_dir/android.policy.jar $onekey_cncalender_dir/android.policy.jar
    oldpwd=`pwd`
    cd $onekey_cncalender_dir/
    printf "\nI:正在制作农历锁屏.."
    ./onekey_add_cn_calender.sh &> /dev/null
    cd $oldpwd
    printf "\nI:制作的农历锁屏已完成，正进行zipalign.."
    mkdir -p $undo_cncalender_dir/jar_new
    $zipalign -v 4  $onekey_cncalender_dir/jar_new/framework.jar $undo_cncalender_dir/jar_new/framework.jar &> /dev/null
    $zipalign -v 4  $onekey_cncalender_dir/jar_new/android.policy.jar $undo_cncalender_dir/jar_new/android.policy.jar &> /dev/null
    printf "\nI:所有操作已完成，恭喜! `date +%F` `date +%X`"
fi

#提示信息:
printf "\n\n支持农历锁文件已位于$(basename $undo_cncalender_dir)/jar_new/目录下\n\n"
read -p "请按下任意键返回主菜单:"
$TOPDIR/scue_kitchen.sh
