#!/bin/bash

#dir
TOPDIR=$(pwd)
scripts_dir=$TOPDIR/linkscue-scripts
sub_menu_dir=$scripts_dir/menu_scripts
zipalign=$TOPDIR/linkscue-scripts/zipalign

wd=$1
unpack1=$scripts_dir/huawei_unpack_official_rom/unpack_1.py
unpack2=$scripts_dir/huawei_unpack_official_rom/unpack_2.py
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
echo "I:执行精确解压.."
$unpack1 UPDATE.APP &> /dev/null
if [[ -f $wd/INPUT.img ]]; then
    printf "\nI:精确解压失败，转为普通解压..\n"
    rm -f $wd/INPUT.img &> /dev/null
    $unpack2 UPDATE.APP
    for (( i = 1; i < 10; i++ )); do
        mv out_$i.img out_0$i.img
    done
else
    printf "\nI:精确解压成功!\n"
fi
mkdir -p $wd/output &> /dev/null
mv -f $wd/*.img $wd/output/
cd $TOPDIR

echo "
解压完毕，解压文件放置于$(basename $wd)/output/
"
echo ""
read -p "请按任意键返回主菜单:"
$TOPDIR/scue_kitchen.sh
