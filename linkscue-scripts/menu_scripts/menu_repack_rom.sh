#!/bin/bash - 
#===============================================================================
#
#          FILE: menu_repack_rom.sh
# 
#         USAGE: ./menu_repack_rom.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: linkscue (scue), linkscue@gmail.com
#       CREATED: 2013年04月10日 21时37分01秒 HKT
#     COPYRIGHT: Copyright (c) 2013, linkscue
#      REVISION: 0.1
#  ORGANIZATION: ATX风雅组
#===============================================================================

script_self=$(readlink -f $0)
#顶级目录变量
TOPDIR=${script_self%/linkscue-scripts/menu_scripts/menu_repack_rom.sh}
scripts_dir=$TOPDIR/linkscue-scripts

clear
echo ""
echo "欢迎使用linkscue 一键制作ROM厨房工具！"
echo ""
echo "请注意Android4.0以下的操作系统并没有实测"
echo ""
echo "此工具将会直接把你的手机system data cache等分区直接打包成一个zip卡刷包"
echo ""
read -p "准备开始，准备好了吗？[Y/n]："
if [[ $REPLY == "n" ]]; then                    # 假如输入了n将会直接退出上一级菜单
    $TOPDIR/scue_kitchen.sh
fi

#检测adb命令是否存在
if [[ "$(which adb)" == "" ]]; then
    echo ""
    read -p "警告：发现adb尚未配置好，是否允许本程序自动配置?[Y/n]: "
    if [[ $REPLY != "n" ]]; then
       sudo ls &> /dev/null
       sudo apt-get install android-tools-adb
       sudo apt-get install android-tools-fastboot
    else
       #返回子菜单界面
       echo ""
       read -p "请按任意键返回菜单:"
       $script_self $wd
    fi
fi

#检测是否连接着有手机
while [[ "$(adb devices | sed -n "$(($(adb devices | sed -n '/List of devices attached/=')+1)) p")" == "" ]]; do
    echo ""
    read -p "警告：未连接有设备，请尝试只连接一台设备: "
done

#检测是否能正常连接上手机
if [[ $(adb devices | grep "no permissions") != "" ]]; then
    echo ""
    read -p "警告：发现adb无法连接手机，是否允许本程序自动配置USB连接?[Y/n]"
    if [[ $REPLY != "n" ]]; then
        sudo ls &> /dev/null
        sudo cp $usb_rule /etc/udev/rules.d/51-android.rules
        sudo chmod 764 /etc/udev/rules.d/51-android.rules
        echo ""
        read -p "USB连接配置已完成，请拔插一次USB端口生效: "
    fi
fi

#请选择将要操作的设备
devices=$(adb devices | grep -w device | awk '{print $1}')
echo ""
echo "请选择将要操作的设备:"
select device in $devices;do
    echo ""
    echo "您选择的设备是: $device"
    break
done

$TOPDIR/linkscue-scripts/repack_rom/tools.sh
echo ""
read -p "操作完成，请按任意键返回上一级菜单."
$TOPDIR/scue_kitchen.sh
