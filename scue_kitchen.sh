#!/bin/bash
#version:0.1
#author:linkscue
#e-mail:linkscue@gmail.com

#top work directory
topwd=$(pwd)

#linkscue kitchen top directory
kitchen_self=$(readlink -f $0)
dir_self=$(dirname $kitchen_self)
TOPDIR=$dir_self
scripts_dir=$TOPDIR/linkscue-scripts
sub_menu_dir=$scripts_dir/menu_scripts
zipalign=$TOPDIR/linkscue-scripts/zipalign

#init
clear
chmod -R 755 $scripts_dir/*

#list the menu
echo "
欢迎使用linkscue ROM定制厨房工具！"

echo "
 1) bootimg相关选项；
 2) 制作Framework农历锁屏显示(支持ICS、JB)；
 3) 制作Framework全局背景透明(支持ICS、JB)；
 4) 清理已移除程序残留的非必需库文件；
 5) 解压华为UPDATE.APP文件；
 6) 自定义华为data空间大小；
 7) 合并odex与分离odex；
 8) 联想特殊szb格式；
 9) 签名工具；

99) 直接制作成zip卡刷包；
 0) 作者及版本信息;
 x) 退出；
"

#get option
read -p "请输入选项:" opt
echo ""
case $opt in
    1) work_boot_dir=$topwd/work_boot_`date +"%Y%m%d_%H%M%S"`
       work_boot_old=$topwd/$(ls -1 | grep work_boot_)
       work_boot_bak=$topwd/work_boot_bak
       if [[ $work_boot_old != "$topwd/" ]]; then
           read -p "发现旧的boot.img工作目录$(basename $work_boot_old)，是否继续使用它？[Y/n]"
           if [[ $REPLY == "n" ]]; then
               mv $work_boot_old $work_boot_bak
               mkdir -p $work_boot_dir
               $sub_menu_dir/menu_bootimgs.sh $work_boot_dir
           else 
               $sub_menu_dir/menu_bootimgs.sh $work_boot_old
           fi
       else
           mkdir -p $work_boot_dir
           $sub_menu_dir/menu_bootimgs.sh $work_boot_dir
       fi
       ;;
     2) work_cncal_dir=$topwd/work_cncal_`date +"%Y%m%d_%H%M%S"`
        work_cncal_old=$topwd/$(ls -1 | grep work_cncal_)
        work_cncal_bak=$topwd/work_cncal_bak
        if [[ $work_cncal_old != "$topwd/" ]]; then
           read -p "发现旧的农历锁屏工作目录$(basename $work_cncal_old)，是否继续使用它？[Y/n]"
           if [[ $REPLY == "n" ]]; then
               mv $work_cncal_old $work_cncal_bak
               mkdir -p $work_cncal_dir
               $sub_menu_dir/menu_cncal.sh $work_cncal_dir
           else 
               $sub_menu_dir/menu_cncal.sh $work_cncal_old
           fi
       else
           mkdir -p $work_cncal_dir
           $sub_menu_dir/menu_cncal.sh $work_cncal_dir
       fi
       ;;
     3) work_fwtp_dir=$topwd/work_fwtp_`date +"%Y%m%d_%H%M%S"`
        work_fwtp_old=$topwd/$(ls -1 | grep work_fwtp_)
        work_fwtp_bak=$topwd/work_fwtp_bak
        if [[ $work_fwtp_old != "$topwd/" ]]; then
           read -p "发现旧的全局透明工作目录$(basename $work_fwtp_old)，是否继续使用它？[Y/n]"
           if [[ $REPLY == "n" ]]; then
               mv $work_fwtp_old $work_fwtp_bak
               mkdir -p $work_fwtp_dir
               $sub_menu_dir/menu_fwtp.sh $work_fwtp_dir
           else 
               $sub_menu_dir/menu_fwtp.sh $work_fwtp_old
           fi
       else
           mkdir -p $work_fwtp_dir
           $sub_menu_dir/menu_fwtp.sh $work_fwtp_dir
       fi
       ;;
     4) work_rmlib_dir=$topwd/work_rmlib_`date +"%Y%m%d_%H%M%S"`
        work_rmlib_old=$topwd/$(ls -1 | grep work_rmlib_)
        work_rmlib_bak=$topwd/work_rmlib_bak
        if [[ $work_rmlib_old != "$topwd/" ]]; then
           read -p "发现旧的rmlib工作目录$(basename $work_rmlib_old)，是否继续使用它？[Y/n]"
           if [[ $REPLY == "n" ]]; then
               mv $work_rmlib_old $work_rmlib_bak
               mkdir -p $work_rmlib_dir
               $sub_menu_dir/menu_rmlib.sh $work_rmlib_dir
           else 
               $sub_menu_dir/menu_rmlib.sh $work_rmlib_old
           fi
       else
           mkdir -p $work_rmlib_dir
           $sub_menu_dir/menu_rmlib.sh $work_rmlib_dir
       fi
       ;;
     5) work_unpackapp_dir=$topwd/work_unpackapp_`date +"%Y%m%d_%H%M%S"`
        work_unpackapp_old=$topwd/$(ls -1 | grep work_unpackapp_)
        work_unpackapp_bak=$topwd/work_unpackapp_bak
        if [[ $work_unpackapp_old != "$topwd/" ]]; then
           read -p "发现旧的unpackapp工作目录$(basename $work_unpackapp_old)，是否继续使用它？[Y/n]"
           if [[ $REPLY == "n" ]]; then
               mv $work_unpackapp_old $work_unpackapp_bak
               mkdir -p $work_unpackapp_dir
               $sub_menu_dir/menu_unpackapp.sh $work_unpackapp_dir
           else 
               $sub_menu_dir/menu_unpackapp.sh $work_unpackapp_old
           fi
       else
           mkdir -p $work_unpackapp_dir
           $sub_menu_dir/menu_unpackapp.sh $work_unpackapp_dir
       fi
       ;;
     6) work_repart_dir=$topwd/work_repart_`date +"%Y%m%d_%H%M%S"`
        work_repart_old=$topwd/$(ls -1 | grep work_repart_)
        work_repart_bak=$topwd/work_repart_bak
        if [[ $work_repart_old != "$topwd/" ]]; then
           read -p "发现旧的repart工作目录$(basename $work_repart_old)，是否继续使用它？[Y/n]"
           if [[ $REPLY == "n" ]]; then
               mv $work_repart_old $work_repart_bak
               mkdir -p $work_repart_dir
               $sub_menu_dir/menu_repart.sh $work_repart_dir
           else 
               $sub_menu_dir/menu_repart.sh $work_repart_old
           fi
       else
           mkdir -p $work_repart_dir
           $sub_menu_dir/menu_repart.sh $work_repart_dir
       fi
       ;;
     7) work_odex_dir=$topwd/work_odex_`date +"%Y%m%d_%H%M%S"`
        work_odex_old=$topwd/$(ls -1 | grep work_odex_)
        work_odex_bak=$topwd/work_odex_bak
        if [[ $work_odex_old != "$topwd/" ]]; then
           read -p "发现旧的odex工作目录$(basename $work_odex_old)，是否继续使用它？[Y/n]"
           if [[ $REPLY == "n" ]]; then
               mv $work_odex_old $work_odex_bak
               mkdir -p $work_odex_dir
               $sub_menu_dir/menu_odex.sh $work_odex_dir
           else 
               $sub_menu_dir/menu_odex.sh $work_odex_old
           fi
       else
           mkdir -p $work_odex_dir
           $sub_menu_dir/menu_odex.sh $work_odex_dir
       fi
       ;;
     8) work_szb_dir=$topwd/work_szb_`date +"%Y%m%d_%H%M%S"`
        work_szb_old=$topwd/$(ls -1 | grep work_szb_)
        work_szb_bak=$topwd/work_szb_bak
        if [[ $work_szb_old != "$topwd/" ]]; then
           read -p "发现旧的szb工作目录$(basename $work_szb_old)，是否继续使用它？[Y/n]"
           if [[ $REPLY == "n" ]]; then
               mv $work_szb_old $work_szb_bak
               mkdir -p $work_szb_dir
               $sub_menu_dir/menu_szb.sh $work_szb_dir
           else 
               $sub_menu_dir/menu_szb.sh $work_szb_old
           fi
       else
           mkdir -p $work_szb_dir
           $sub_menu_dir/menu_szb.sh $work_szb_dir
       fi
       ;;
     9) work_sign_dir=$topwd/work_sign_`date +"%Y%m%d_%H%M%S"`
        work_sign_old=$topwd/$(ls -1 | grep work_sign_)
        work_sign_bak=$topwd/work_sign_bak
        if [[ $work_sign_old != "$topwd/" ]]; then
           read -p "发现旧的sign工作目录$(basename $work_sign_old)，是否继续使用它？[Y/n]"
           if [[ $REPLY == "n" ]]; then
               mv $work_sign_old $work_sign_bak
               mkdir -p $work_sign_dir
               $sub_menu_dir/menu_sign.sh $work_sign_dir
           else 
               $sub_menu_dir/menu_sign.sh $work_sign_old
           fi
       else
           mkdir -p $work_sign_dir
           $sub_menu_dir/menu_sign.sh $work_sign_dir
       fi
       ;;
     99) $sub_menu_dir/menu_repack_rom.sh
     ;;
     0) $sub_menu_dir/menu_author.sh
     ;;
     x) clear;
        printf "\n拜拜，下次再见! #^_^# \n\n"
        exit 0
        ;;
     *) $TOPDIR/scue_kitchen.sh
     ;;
esac
