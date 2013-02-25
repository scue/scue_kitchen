#!/bin/bash
#实现功能：针对华为荣耀2,海思平台，解压boot.img及recovery.img

#自身位置
script_self=$(readlink -f $0)
dir_self=$(dirname $script_self)
unpackbootimg=$dir_self/unpackbootimg
unpackbootimg_pl=$dir_self/unpack-bootimg.pl

#顶层位置
TOPDIR=${script_self%/linkscue-scripts/bootimg-scripts-advance/unpack-hisilicon-scue.sh}
scripts_dir=$TOPDIR/linkscue-scripts
sub_menu_dir=$scripts_dir/menu_scripts
zipalign=$TOPDIR/linkscue-scripts/zipalign

#bootimg.py位置
bootimg=$TOPDIR/linkscue-scripts/bootimg-scripts-common/bootimg.py

#传入参数
wd=$1
boot=${2:-'boot.img'}
log=${3:-'bootimg.log'}
oldwd=$(pwd)

#切换至工作目录
cd $wd
tmp=tmp_$$.txt

#剪切前边0x800大小的信息
dd if=$boot of=${boot}_nohead bs=$((0x800)) skip=1
$bootimg --unpack-bootimg ${boot}_nohead 2> $tmp
$bootimg --unpack-ramdisk ramdisk.gz
rm -f ${boot}_nohead

#把boot.img解压信息写入指定位置
array=( base cmdline page_size padding_size )
for param in ${array[@]}; do
    cat $tmp | grep $param | awk -F'=' '{print $2}' > $boot-$param
done
rm -f $tmp

#退出工作目录
cd $oldwd
