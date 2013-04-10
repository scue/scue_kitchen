#!/bin/bash - 
#===============================================================================
#
#          FILE: $self_dir/tools.sh
# 
#         USAGE: $self_dir/tools.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: linkscue (scue), linkscue@gmail.com
#       CREATED: 2013年04月10日 20时30分37秒 HKT
#     COPYRIGHT: Copyright (c) 2013, linkscue
#      REVISION: 0.1
#  ORGANIZATION: ATX破晓组
#===============================================================================

#top work directory
#topwd=$(pwd)

self_script=$(readlink -f $0)
self_dir=$(dirname $self_script)

clear

#开始进入操作界面；
echo "==============================================================="
echo "          欢迎使用Android手机固件制作集成工具箱"
echo "                                  版本：0.12"
echo "                                  作者：linkscue"
echo "==============================================================="
echo ""
echo "准备工作"
echo "  1. 手机已ROOT；"
echo "  2. 手机打开USB调试；"
echo "  3. 手机正常开机状态下连接至电脑；"
echo "  4. 电脑端安装好驱动程序并能正确连接手机；"
echo ""

#检测是否能正确连接手机，并设置好相应的权限；
echo "<<< 正在检测adb是否能正确连接手机.."
adb shell 'su -c chmod 777 -R /data/local/tmp' >/dev/null 
if [[ $? != 0 ]]; then
    echo ">>> 手机尚未正确连接至电脑!"
    exit 1
else
    echo ">>> 手机正常连接。"
fi

#开始上传必须的工具至手机
adb push $self_dir/tools/META-INF /data/local/tmp/META-INF 2>/dev/null
adb push $self_dir/tools/busybox /data/local/tmp/busybox 2>/dev/null
adb push $self_dir/tools/backup_rom_unix.sh /data/local/tmp/backup_rom_unix.sh 2>/dev/null 
adb push $self_dir/tools/mount_data.sh /data/local/tmp/mount_data.sh 2>/dev/null 
adb push $self_dir/tools/restore_rom.sh /data/local/tmp/restore_rom.sh 2>/dev/null
adb push $self_dir/tools/zip /data/local/tmp/zip 2>/dev/null
adb shell < $self_dir/tools/tools_permissions >/dev/null
adb shell su -c /data/local/tmp/backup_rom_unix.sh

#清除文件
if [[ $? == 0 ]]; then                          # 检测已成功运行上一条命令再执行清空
    adb shell < $self_dir/tools/tools_erase >/dev/null
else 
    echo "制作成zip卡刷包失败，请重新操作!"
    exit 1
fi
