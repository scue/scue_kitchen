#!/bin/bash
#version:0.1
#author:linkscue@gmail.com
#文件名称:~/bin/mkcncalender
#实现功能:调用一键制作农历锁屏来制作农历锁屏

if [[ $# != 1 ]]; then
    echo "usage:`basename $0` [system/framework/]"
    exit 1
fi

#需要制作一键农历锁屏的目录
undo_cncalender_dir=${1%/*}

#一键制作农历锁屏工具位置
onekey_cncalender_dir=/home/scue/apktool/linkscue-scripts/mkcncalender

#开始制作农历锁屏
echo "I:正拷贝必需的文件.."
mv -f $undo_cncalender_dir/framework.jar $onekey_cncalender_dir/framework.jar
mv -f $undo_cncalender_dir/android.policy.jar $onekey_cncalender_dir/android.policy.jar
oldpwd=`pwd`
cd $onekey_cncalender_dir/
echo "I:正在制作农历锁屏.."
./onekey_add_cn_calender.sh &> /dev/null
cd $oldpwd
echo "I:制作的农历锁屏已完成，正进行zipalign.."
zipalign -v 4  $onekey_cncalender_dir/jar_new/framework.jar $undo_cncalender_dir/framework.jar &> /dev/null
zipalign -v 4  $onekey_cncalender_dir/jar_new/android.policy.jar $undo_cncalender_dir/android.policy.jar &> /dev/null
echo "I:所有操作已完成，恭喜! `date +%F` `date +%X`"
