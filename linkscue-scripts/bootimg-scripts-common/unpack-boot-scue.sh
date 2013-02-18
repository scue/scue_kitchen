#!/bin/bash

img=boot.img
tmp=tmp_$$.txt
bootimg=../linkscue-scripts/bootimg-scripts-common/bootimg.py

$bootimg --unpack-bootimg $img 2> $tmp

array=( base cmdline page_size padding_size )
for param in ${array[@]}; do
    cat $tmp | grep $param | awk -F'=' '{print $2}' > $img-$param
done

$bootimg --unpack-ramdisk ramdisk.gz

rm -f $tmp
