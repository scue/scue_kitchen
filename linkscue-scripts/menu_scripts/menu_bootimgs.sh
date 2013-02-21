#!/bin/bash

#self
script_self=$(readlink -f $0)

#dir
TOPDIR=${script_self%/linkscue-scripts/menu_scripts/menu_bootimgs.sh}
scripts_dir=$TOPDIR/linkscue-scripts
sub_menu_dir=$scripts_dir/menu_scripts

#list the menu
clear
echo "
欢迎使用linkscue bootimg定制厨房工具！"

echo "
 1) 解压boot.img（通用）；
 2) 解压boot.img（MTK平台）；
 3) 解压boot.img（三星平台）；
 4) ramdisk中添加root权限；
 5) ramdisk中添加busybox全部命令；
 6) ramdisk中添加/system/etc/init.d自定义脚本支持；
 7) 打包boot.img（通用）；
 8) 打包boot.img（MTK平台）；
 9) 打包boot.img（三星平台）；

 b) 返回主菜单；
"

#specify work bootimg dir
wd=$1
oldwd=${2:-$(pwd)}

#dir
bootimg_common_dir=$scripts_dir/bootimg-scripts-common
bootimg_exynos_dir=$scripts_dir/bootimg-scripts-exynos
bootimg_mtk_dir=$scripts_dir/bootimg-scripts-mtk
mkbootimg=$bootimg_common_dir/mkbootimg

#info
echo "当前工作目录是 $(basename $wd);

请把boot.img放置于 $(basename $wd); 

当前boot.img工作目录信息：
"
if [[ -e $wd/bootimg.log ]]; then
    cat $wd/bootimg.log | while read line;do
        case $line in
            "common") echo "a) 通用平台";;
            "MTK") echo "a) MTK平台";;
            "exynos") echo "a) 三星平台";;
            "unpack is ok!") echo "b) boot.img已解压";;
            "rooted") echo "c) ramdisk已root";;
            "busybox") echo "d) busybox已添加";;
            "init.d") echo "e) init.d自定义脚本已支持";;
            "repack is ok!") echo "f) boot.img已打包，新文件是boot_new.img";;
        esac
    echo ""
    done
else 
    echo "（空）"
    echo ""
fi

#get option
read -p "请输入选项:" opt
while [[ ! -f $wd/boot.img ]]; do
    read -p "请把boot.img放置于$wd!"
done
case $opt in
    1) cd $wd
	   rm -rf initrd &> /dev/null
       $bootimg_common_dir/unpack-boot-scue.sh
       if [[ $? == 0 ]]; then
           echo "common" > $wd/bootimg.log
           echo "unpack is ok!" >> $wd/bootimg.log
       fi
       $script_self $wd
       ;;
    2) cd $wd
       $bootimg_mtk_dir/unpack-MT65xx.sh boot.img
       if [[ $? == 0 ]]; then
           echo "MTK" > $wd/bootimg.log
           echo "unpack is ok!" >> $wd/bootimg.log
       fi
       $script_self $wd $oldwd
       ;;
    3) cd $wd
       $bootimg_exynos_dir/unpack-exynos-boot.sh boot.img
       if [[ $? == 0 ]]; then
           echo "exynos" > $wd/bootimg.log
           echo "unpack is ok!" >> $wd/bootimg.log
       fi
       $script_self $wd $oldwd
       ;;
    4) cd $wd
       $bootimg_common_dir/ramdisk_root.sh
       if [[ $? == 0 ]]; then
           echo "rooted" >> $wd/bootimg.log
       fi
       $script_self $wd
       ;;
    5) cd $wd
       $bootimg_common_dir/ramdisk_busybox.sh
       if [[ $? == 0 ]]; then
           echo "busybox" >> $wd/bootimg.log
       fi
       $script_self $wd $oldwd
       ;;
    6) cd $wd
       $bootimg_common_dir/ramdisk_init.d.sh
       if [[ $? == 0 ]]; then
           echo "init.d" >> $wd/bootimg.log
       fi
       $script_self $wd $oldwd
       ;;
    7) cd $wd
       $bootimg_common_dir/repack-boot-scue.sh kernel initrd boot_new.img
        
       if [[ $? == 0 ]]; then
           echo "repack is ok!" >> $wd/bootimg.log
       fi
       $script_self $wd $oldwd
       ;;
    8) cd $wd
       $bootimg_mtk_dir/repack-MT65xx.sh -boot boot.img-kernel.img boot.img-ramdisk boot_new.img $mkbootimg
       if [[ $? == 0 ]]; then
           echo "repack is ok!" >> $wd/bootimg.log
       fi
       $script_self $wd $oldwd
       ;;
    9) cd $wd
       $bootimg_exynos_dir/repack-exynos-boot.sh kernel initrd/ boot_new.img
       if [[ $? == 0 ]]; then
           echo "repack is ok!" >> $wd/bootimg.log
       fi
       $script_self $wd $oldwd
       ;;

    b) cd $oldwd
       $TOPDIR/scue_kitchen.sh
       ;;
    *) $script_self $wd $oldwd
       ;;
esac
