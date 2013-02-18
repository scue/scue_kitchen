#!/bin/bash
# Version: 0.1
# Author: linkscue
# E-mail: linkscue@gmail.com
# Put what apks you want to remove to rm_app or delapp dir;
# Or you can also add a diretory to dir_array, Enjoy!

#dir
TOPDIR=$(pwd)
scripts_dir=$TOPDIR/linkscue-scripts
sub_menu_dir=$scripts_dir/menu_scripts
zipalign=$TOPDIR/linkscue-scripts/zipalign

wd=$1
lib_dir=$wd/lib
dir_array=(\
 $wd/rm_app\
)

#make directory
cd $wd
mkdir -p $lib_dir
mkdir -p ${dir_array[@]}

#init
clear
echo "
欢迎使用linkscue 清理残余库文件定制厨房工具！"
echo "
操作说明：

1. 把手机/syste/lib/目录上所有的文件复制到$(basename $wd)/lib/目录; 

2. 把手机/system/app/目录上，将需要删除的“程序”复制到$(basename $wd)/rm_app/目录；
"
read -p "以上操作完成后，按下任意键进行清理残余的库文件:"

while [[ $(ls -1 $lib_dir) == "" ]];do
echo ""
read -p "请把系统全部库文件[/system/lib/]放置于$(basename $wd)/lib/目录下:" 
done

if [[ ! -d $lib_dir ]]; then
    echo "I: can't find $lib_dir!"
    exit 1
else 
    echo ""
    if [[ -e rm_lib_list.txt ]]; then
        rm -vf rm_lib_list.txt &> /dev/null
    fi
    for x in ${dir_array[@]};do 
        if [[ -d $x ]]; then
            ls -1 $x > rm_app_list.txt
            cat rm_app_list.txt | while read line
            do 
                echo "I: rm $line's lib.. " 
                unzip -l $x/$line | awk '{print $4}' | grep ^lib | awk -F'/' '{print $3}' \
                >> rm_lib_list.txt
            done
            
        fi
    done
    cat rm_lib_list.txt | while read lib_line
    do
        rm -f $lib_dir/$lib_line &> /dev/null
    done
fi
count1=$(cat rm_app_list.txt | wc -l)
count2=$(cat rm_lib_list.txt | wc -l)
cd $TOPDIR

#init
#clear
#echo "
#欢迎使用linkscue 清理残余库文件定制厨房工具！"
#echo "
#操作说明：
#
#1. 把手机/syste/lib/目录上所有的文件复制到$(basename $wd)/lib/目录; 
#
#2. 把手机/system/app/目录上，将需要删除的“程序”复制到$(basename $wd)/rm_app/目录；
#"
echo "
本次一共清理 $count1 个程序所涉及的残余库文件共 $count2 个；

清理$(basename $wd)/$(basename ${dir_array[@]})程序残留于的库文件已完成；

请删除刷机包内的/system/lib/目录上的文件，并使用$(basename $wd)/$(basename $lib_dir)目录内的库文件替换之；"

echo ""
read -p "请按任意键返回主菜单:"
$TOPDIR/scue_kitchen.sh
