#!/bin/bash

clear

#dir
TOPDIR=$(pwd)
scripts_dir=$TOPDIR/linkscue-scripts
sub_menu_dir=$scripts_dir/menu_scripts

#list the menu
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
boot_dir=$1

#dir
bootimg_common_dir=$scripts_dir/bootimg-scripts-common
bootimg_exynos_dir=$scripts_dir/bootimg-scripts-exynos
bootimg_mtk_dir=$scripts_dir/bootimg-scripts-mtk
oldwd=`pwd`

#info
echo "当前工作目录是 $(basename $boot_dir);

请把boot.img放置于 $(basename $boot_dir); 

当前boot.img工作目录信息：
"
if [[ -e $boot_dir/bootimg.log ]]; then
    cat $boot_dir/bootimg.log | while read line;do
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
while [[ ! -f $boot_dir/boot.img ]]; do
    read -p "请把boot.img放置于$boot_dir!"
done
case $opt in
    1) cd $boot_dir
	   rm -rf initrd &> /dev/null
       $bootimg_common_dir/unpack-boot-scue.sh
       if [[ $? == 0 ]]; then
           echo "common" > $boot_dir/bootimg.log
           echo "unpack is ok!" >> $boot_dir/bootimg.log
       fi
       cd $oldwd
       $sub_menu_dir/menu_bootimgs.sh $boot_dir
       ;;
    2) cd $boot_dir
       $bootimg_mtk_dir/unpack-MT65xx.sh boot.img
       if [[ $? == 0 ]]; then
           echo "MTK" > $boot_dir/bootimg.log
           echo "unpack is ok!" >> $boot_dir/bootimg.log
       fi
       cd $oldwd
       $sub_menu_dir/menu_bootimgs.sh $boot_dir
       ;;
    3) cd $boot_dir
       $bootimg_exynos_dir/unpack-exynos-boot.sh boot.img
       if [[ $? == 0 ]]; then
           echo "exynos" > $boot_dir/bootimg.log
           echo "unpack is ok!" >> $boot_dir/bootimg.log
       fi
       cd $oldwd
       $sub_menu_dir/menu_bootimgs.sh $boot_dir
       ;;
    4) cd $boot_dir
       $bootimg_common_dir/ramdisk_root.sh
       if [[ $? == 0 ]]; then
           echo "rooted" >> $boot_dir/bootimg.log
       fi
       cd $oldwd
       $sub_menu_dir/menu_bootimgs.sh $boot_dir
       ;;
    5) cd $boot_dir
       $bootimg_common_dir/ramdisk_busybox.sh
       if [[ $? == 0 ]]; then
           echo "busybox" >> $boot_dir/bootimg.log
       fi
       cd $oldwd
       $sub_menu_dir/menu_bootimgs.sh $boot_dir
       ;;
    6) cd $boot_dir
       $bootimg_common_dir/ramdisk_init.d.sh
       if [[ $? == 0 ]]; then
           echo "init.d" >> $boot_dir/bootimg.log
       fi
       cd $oldwd
       $sub_menu_dir/menu_bootimgs.sh $boot_dir
       ;;
    7) cd $boot_dir
       $bootimg_common_dir/repack-boot-scue.sh kernel initrd boot_new.img
        
       if [[ $? == 0 ]]; then
           echo "repack is ok!" >> $boot_dir/bootimg.log
       fi
       cd $oldwd
       $sub_menu_dir/menu_bootimgs.sh $boot_dir
       ;;
    8) cd $boot_dir
       $bootimg_mtk_dir/repack-MT65xx.sh -boot boot.img-kernel.img boot.img-ramdisk boot_new.img
       if [[ $? == 0 ]]; then
           echo "repack is ok!" >> $boot_dir/bootimg.log
       fi
       cd $oldwd
       $sub_menu_dir/menu_bootimgs.sh $boot_dir
       ;;
    9) cd $boot_dir
       $bootimg_exynos_dir/repack-exynos-boot.sh kernel initrd/ boot_new.img
       if [[ $? == 0 ]]; then
           echo "repack is ok!" >> $boot_dir/bootimg.log
       fi
       cd $oldwd
       $sub_menu_dir/menu_bootimgs.sh $boot_dir
       ;;

    b) $TOPDIR/scue_kitchen.sh
       ;;
    *) $sub_menu_dir/menu_bootimgs.sh $boot_dir
       ;;
esac
