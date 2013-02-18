#!/bin/bash

if [[ $# != 1 ]]; then
    echo "usage:`basename $0` [framework-res.apk] "
    exit 1
fi

#顶级目录变量
TOPDIR=$(pwd)
scripts_dir=$TOPDIR/linkscue-scripts
sub_menu_dir=$scripts_dir/menu_scripts
zipalign=$TOPDIR/linkscue-scripts/zipalign

framework_res_apk=$1
framework_res_dir=${1%.*}
framework_res_dirname=`dirname $framework_res_apk`
framework_res_new=$framework_res_dirname/framework-res_new.apk
style=$framework_res_dir/res/values/styles.xml
color=$framework_res_dir/res/values/colors.xml
change_xml=$scripts_dir/mkframeworktp/change_xml.sh
merge_apk=$scripts_dir/apktool/mergeapk.sh
apktool=$scripts_dir/apktool/apktool

if [[ ! -e $framework_res_apk ]]; then
    echo "I: can't find the framework-res.apk"
    exit 1
else 
    $apktool d -f $framework_res_apk $framework_res_dir &> /dev/null
    if [[ $? != 0 ]]; then
        echo "I: please install apktool to ~/bin/apktool."
        exit 1
    else
        $change_xml $style $color 
        $merge_apk -r $framework_res_dir $framework_res_new
        echo 'I: the new transparent apk is framework-res_new.apk.'
    fi

fi

