#!/bin/bash

ramdisk_dir=$(find . -type d | sed -n '2p')
prop_file=$ramdisk_dir/default.prop
tmp1=tmp_$$.txt
tmp2=tmp_$$_$$.txt
sed -e '/ro.secure/c\ro.secure=0' -e '/ro.allow.mock.location/c\ro.allow.mock.location=1' -e '/ro.debuggable/c\ro.debuggable=1' $prop_file | tee $tmp1
if [[ $(grep persist.service.adb.enable $tmp1) == "" ]]; then
    sed '/ro.debuggable/a\persist.service.adb.enable=1' $tmp1 | tee $tmp2
else 
    mv $tmp1 $tmp2
fi
mv $tmp2 $prop_file
if [[ -f $tmp1 ]]; then
   rm $tmp1 
fi
