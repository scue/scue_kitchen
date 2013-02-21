#!/bin/bash

#self
script_self=$(readlink -f $0)

#顶级目录变量
TOPDIR=${script_self%/linkscue-scripts/menu_scripts/menu_sign.sh}
scripts_dir=$TOPDIR/linkscue-scripts
sub_menu_dir=$scripts_dir/menu_scripts
zipalign=$TOPDIR/linkscue-scripts/zipalign

#脚本自身相关变量
wd=$1
sign_common=$scripts_dir/sign_files/tool_sign_common.sh
sign_system=$scripts_dir/sign_files/tool_sign_system.sh
sign_lenovo=$scripts_dir/sign_files/tool_sign_lenovo_zip.sh

#创建目录
mkdir -p $wd/unsign_common
mkdir -p $wd/unsign_system
mkdir -p $wd/unsign_lenovo
signed_common=$wd/signed_common_`date +"%Y%m%d_%H%M%S"`
signed_system=$wd/signed_system_app_`date +"%Y%m%d_%H%M%S"`
signed_lenovo=$wd/signed_lenovo_zip_`date +"%Y%m%d_%H%M%S"`

#初始化
clear
echo "
欢迎使用linkscue 签名定制厨房工具！"
echo "
操作说明：

1. 把普通应用程序或卡刷包zip放置于$(basename $wd)/unsign_common/; 

2. 把系统应用程序放置于$(basename $wd)/unsign_system_app/;

3. 把联想K860/K860i卡刷包zip放置于$(basename $wd)/unsign_lenovo_zip/;
"
read -p "以上操作完成后，按任意键以继续:"
echo ""
#普通应用程序、卡刷包签名；
list_common="$(ls -1 $wd/unsign_common/* 2> /dev/null)" 
list_system="$(ls -1 $wd/unsign_system/* 2> /dev/null)" 
list_lenovo="$(ls -1 $wd/unsign_lenovo/* 2> /dev/null)" 
if [[ "$list_common" != "" ]]; then
    mkdir $signed_common
    echo "I: 正对$(basename $wd)/unsign_common/内文件进行签名 .."
    for n in ${list_common[@]};do
        $sign_common $n &> /dev/null
        mv ${n%.apk}_Signed.apk $signed_common/ &> /dev/null
        mv ${n%.zip}_Signed.zip $signed_common/ &> /dev/null
    done
    echo "I: 签名完成，输出文件在$(basename $wd)/$(basename $signed_common)/"
fi

if [[ "$list_system" != "" ]]; then
    mkdir $signed_system
    echo "I: 正对$(basename $wd)/unsign_system/内文件进行签名 .."
    for n in ${list_system[@]};do
        $sign_system $n &> /dev/null
        mv ${n%.apk}_Signed.apk $signed_system/ &> /dev/null
        mv ${n%.zip}_Signed.zip $signed_system/ &> /dev/null
    done
    echo "I: 签名完成，输出文件在$(basename $wd)/$(basename $signed_system)/"

fi

if [[ "$list_lenovo" != "" ]]; then
    mkdir $signed_lenovo
    echo "I: 正对$(basename $wd)/unsign_lenovo/内文件进行签名 .."
    for n in ${list_lenovo[@]};do
        $sign_lenovo $n &> /dev/null
        mv ${n%.apk}_Signed.apk $signed_lenovo/ &> /dev/null
        mv ${n%.zip}_Signed.zip $signed_lenovo/ &> /dev/null
    done
    echo "I: 签名完成，输出文件在$(basename $wd)/$(basename $signed_lenovo)/"
fi
echo "
所有对文件签名工作已经完成。"

#返回主菜单界面
echo ""
read -p "请按任意键返回主菜单:"
$TOPDIR/scue_kitchen.sh
