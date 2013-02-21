#!/bin/bash

#self
script_self=$(readlink -f $0)

#dir
TOPDIR=${script_self%/linkscue-scripts/menu_scripts/menu_repart.sh}
scripts_dir=$TOPDIR/linkscue-scripts
sub_menu_dir=$scripts_dir/menu_scripts
zipalign=$TOPDIR/linkscue-scripts/zipalign

wd=$1
oldwd=$(pwd)
sign_tool=$scripts_dir/sign_files/tool_sign_common.sh 
repart_dir=$scripts_dir/huawei_repart_rom

#init
clear
echo "
欢迎使用linkscue 自定义Data分区空间大小定制厨房工具！"
echo "
当前工作目录是$(basename $wd); 
"
#error detect
cd $repart_dir
while [[ $size == "" ]]; do
    read -p "请输入您需要自定义Data分区的大小值[例如2.0、2.0g或size=2.0G]: "
    size=$(echo $REPLY | grep -o '[0-9]\+\.[0-9]\+')
done
name=repart_huawei${size}g_Signed.zip
#
sed -i "$(sed -n "/size/{=;q}" repart_huawei.sh) c\size=$size" repart_huawei.sh
cp repart_huawei.sh repart_huawei/repart_huawei.sh
echo "
I: 自定义分区脚本repart_huawei.sh已生成，正在打包成分区卡刷包..
"
cd repart_huawei/
zip -r1 ../repart_huawei.zip * &> /dev/null
cd ../
$sign_tool repart_huawei.zip &> /dev/null
cp repart_huawei_Signed.zip $wd/$name
cd $oldwd
echo "I: 自定义data分区${size}g卡刷包已经生成;"
echo "
I: 卡刷包位于$(basename $wd)/$name"
echo ""
read -p "请按任意键返回主菜单:"
$TOPDIR/scue_kitchen.sh
