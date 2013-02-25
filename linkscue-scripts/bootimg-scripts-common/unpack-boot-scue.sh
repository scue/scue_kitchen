#!/bin/bash

#self
script_self=$(readlink -f $0)
dir_self=$(dirname $script_self)

img=boot.img
tmp=tmp_$$.txt
bootimg=$dir_self/bootimg.py

$bootimg --unpack-bootimg $img 2> $tmp

array=( base cmdline page_size padding_size )
for param in ${array[@]}; do
    cat $tmp | grep $param | sed "s/^${param}=//" > $img-$param
done

$bootimg --unpack-ramdisk ramdisk.gz

rm -f $tmp
