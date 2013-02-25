#!/bin/bash

#self
script_self=$(readlink -f $0)

#顶级目录变量
TOPDIR=${script_self%/linkscue-scripts/menu_scripts/menu_odex.sh}
scripts_dir=$TOPDIR/linkscue-scripts
sub_menu_dir=$scripts_dir/menu_scripts
zipalign=$TOPDIR/linkscue-scripts/zipalign

#脚本自身相关变量
wd=$1
oldwd=$(pwd)
odex2dex=$scripts_dir/odex2dex/odex2dex.sh
dex2odex=$scripts_dir/odexopt/dexopt.sh
usb_rule=$scripts_dir/odexopt/51-android.rules
sign_common=$scripts_dir/sign_files/tool_sign_common.sh
sign_system=$scripts_dir/sign_files/tool_sign_system.sh

#初始化
clear
echo ""
echo "欢迎使用linkscue odex合并与分离定制厨房工具！"
echo ""
echo "功能菜单："
echo ""
echo " 1) 合并odex和apk(或jar)；"
echo " 2) 分离odex从apk(或jar)；"
echo ""
echo " b) 返回主菜单；"
echo ""

read -p "请输入选项:" opt
echo ""
case $opt in
1) #合并选项

    #创建目录
    mkdir -p $wd/unmerge_odex &> /dev/null
    mkdir -p $wd/framework &> /dev/null

    echo ""
    echo "操作说明："
    echo ""
    echo "1. 把需要合并odex和apk（或jar）的文件放置于工作目录$(basename $wd)/unmerge_odex/; "
    echo "2. 把手机的/system/framework/全部文件拷贝至工作目录$(basename $wd)/framework/;"
    echo ""
    read -p "以上操作完成后，按任意键以继续:"

    #错误侦测
    while [[ $(ls -1 $wd/framework/) == "" ]]; do
        echo ""
        read -p "请把/system/framework/全部文件拷贝至工作目录$(basename $wd)/framework/:" 
    done
    while [[ $(ls -1 $wd/unmerge_odex/) == "" ]]; do
        echo ""
        read -p "请把需要合并odex和apk的文件拷贝至工作目录$(basename $wd)/unmerge_odex/:" 
    done

    #侦测是否是合并jar与odex文件；
    dectect_jar=$(ls -1 $wd/unmerge_odex/*.jar)
    if [[ "$dectect_jar" != "" ]]; then
        mkdir -p $wd/merged_jar &> /dev/null
        #获取jar文件列表；
        ls -1 $wd/unmerge_odex/*.jar | sed 's/\.jar//g' > $wd/odexed_jarlist.txt

        #逐个取出应用程序并进行odex2dex,工作目录必须是framework下；
        echo "
        I: 正在进行合并操作 .."
        cd $wd/framework
        cat $wd/odexed_jarlist.txt | while read line;do
            cp $line.jar .
            cp $line.odex .
            if [[ -f $line.jar ]] && [[ $line.odex ]]; then
                $odex2dex $line.jar $line.odex
            fi
            cp $(basename $line.jar) ../merged_jar/
        done
        cd $oldwd
        echo ""
        echo "合并操作已完成，输出文件在$(basename $wd)/merged_jar/"
    else
        mkdir -p $wd/merged_apk &> /dev/null
        #获取apk文件列表；
        ls -1 $wd/unmerge_odex/*.apk | sed 's/\.apk//g' > $wd/odexed_apklist.txt

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
            cp $(basename $line.apk) ../merged_apk/
            rm -f $(basename $line).apk 
            rm -f $(basename $line).odex 
        done
        cd $oldwd
        echo ""
        echo "合并操作已完成，输出文件在$(basename $wd)/merged_apk/"
    fi
    #返回子菜单界面
    echo ""
    read -p "请按任意键返回菜单:"
    $script_self $wd
;;
2) #分离选项
    #创建目录
    mkdir -p $wd/unodex_file
    mkdir -p $wd/odexed_odex
    mkdir -p $wd/odexed_file_unsign
    mkdir -p $wd/odexed_file_signed_common
    mkdir -p $wd/odexed_file_signed_system

    #初始化
    echo ""
    echo "操作说明："
    echo ""
    echo "1. 将要使用adb命令，若尚未配置好，需ROOT权限进行自动安装；"
    echo "1. 将要对手机操作，请把你的手机连接至电脑（或虚拟机环境）；"
    echo "2. 请把将要分离出odex文件的apk文件放置于 $wd/unodex_file/:"
    echo ""
    read -p "以上操作完成后，按任意键以继续: "
    
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

    #检测操作目录是否为空
    while [[ "$(ls -1 $wd/unodex_file/*)" == "" ]]; do
        echo ""
        read -p "请把将要分离出odex文件的apk文件放置于 $wd/unodex_file:"
    done
    $dex2odex $device $wd/unodex_file $wd/odexed_odex # &> /dev/null
    echo ""
    echo ">> odex化操作已经完成，输出的odex文件在$wd/odexed_odex/"

    #删除apk文件内的classes.dex文件；
    echo ""
    echo "正在进一步清理odex化后残余于apk或jar文件内的classes.dex .."
    oldwd=$(pwd)
    cd $wd/unodex_file/
    file_list=$(ls -1)
    for file in ${file_list[@]}; do
        tmp_dir=$wd/unodex_file/tmp_unzip
        unzip $file -d $tmp_dir &> /dev/null
        cd $tmp_dir
        rm -f classes.dex
        zip -r1 unsign.apk ./* &> /dev/null
        $sign_common unsign.apk common.apk &> /dev/null
        $sign_system unsign.apk system.apk &> /dev/null
        $zipalign -vf 4 unsign.apk $wd/odexed_file_unsign/$file &> /dev/null
        $zipalign -vf 4 common.apk $wd/odexed_file_signed_common/$file &> /dev/null
        $zipalign -vf 4 system.apk $wd/odexed_file_signed_system/$file &> /dev/null
        cd $wd/unodex_file/
        rm -rf $tmp_dir
        rm -f unsign.apk
        rm -f common.apk
        rm -f system.apk
    done
    cd $oldwd
    echo ""
    echo ">> 未经过签名的odex化后被删除classes.dex的apk或jar文件放置于$wd/odexed_file_unsign/"
    echo ""
    echo ">> 经普通签名的odex化后被删除classes.dex的apk或jar文件放置于$wd/odexed_file_unsign/"
    echo ""
    echo ">> 经系统签名的odex化后被删除classes.dex的apk或jar文件放置于$wd/odexed_file_unsign/"

    #返回子菜单界面
    echo ""
    read -p "请按任意键返回菜单:"
    $script_self $wd
;;
b)
    $TOPDIR/scue_kitchen.sh
;;
*)
    $script_self $wd
;;
esac
