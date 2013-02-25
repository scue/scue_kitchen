#!/bin/bash

#self
script_self=$(readlink -f $0)

#dir
TOPDIR=${script_self%/linkscue-scripts/menu_scripts/menu_advance_bootimg.sh}
scripts_dir=$TOPDIR/linkscue-scripts
sub_menu_dir=$scripts_dir/menu_scripts
dir_bootimg=$scripts_dir/bootimg-scripts-advance
bootimg_mtk_dir=$scripts_dir/bootimg-scripts-mtk
bootimg1=$scripts_dir/bootimg-scripts-advance/unpackbootimg
bootimg2=$scripts_dir/bootimg-scripts-advance/unpack-bootimg.pl
bootimg3=$scripts_dir/bootimg-scripts-advance/unpack-hisilicon-scue.sh
mkbootimg=$scripts_dir/bootimg-scripts-common/mkbootimg

wd=$1
oldwd=$(pwd)

#list the menu
clear
echo ""
echo "欢迎使用linkscue bootimg定制高级菜单！"
echo ""
echo ""
echo "1) 解压boot.img增强版1；"
echo "2) 解压boot.img增强版2；"
echo "3) 解压海思平台boot.img（华为荣耀2专用）；"
echo "4) 打包MTK平台boot.img工作目录为recovery.img;"
echo ""
echo "b) 返回菜单；"
echo ""
read -p "请输入选项：" opt
while [[ ! -f $wd/boot.img ]]; do
    read -p "请把boot.img放置于$wd!"
done
case $opt in
1)
    cd $wd
    $bootimg1 $wd/boot.img
    cd $oldwd
    echo ""
    read -p "按任意键返回菜单:"
    $TOPDIR/linkscue-scripts/menu_scripts/menu_advance_bootimg.sh $wd
;;
2)
    cd $wd
    $bootimg2 $wd/boot.img
    cd $oldwd
    echo ""
    read -p "按任意键返回菜单:"
    $TOPDIR/linkscue-scripts/menu_scripts/menu_advance_bootimg.sh $wd
;;
3)
    cd $wd
    $bootimg3 $wd/boot.img
    cd $oldwd
    echo ""
    read -p "按任意键返回菜单:"
    $TOPDIR/linkscue-scripts/menu_scripts/menu_advance_bootimg.sh $wd
;;
4)
    $bootimg_mtk_dir/repack-MT65xx.sh -recovery boot.img-kernel.img boot.img-ramdisk boot_new.img $mkbootimg
    echo ""
    read -p "按任意键返回菜单:"
    $TOPDIR/linkscue-scripts/menu_scripts/menu_advance_bootimg.sh $wd
;;
b)
    $TOPDIR/linkscue-scripts/menu_scripts/menu_bootimgs.sh $wd
;;
*)
    $TOPDIR/linkscue-scripts/menu_scripts/menu_advance_bootimg.sh $wd
;;
esac
