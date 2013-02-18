#!/bin/bash
if [[ $# != 1 ]]; then
    echo "使用方法：`basename $0` [Decode SystemUI_dir]"
    exit 1
fi
des_dir=$1/res/drawable-xhdpi
png_dir=/home/scue/apktool/linkscue-scripts/jb_nav_keys_for_lenovo
cp $png_dir/*.png $des_dir/
echo "I:拷贝完毕，导航栏图标已修改。"
