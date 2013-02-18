#!/bin/bash
#version:0.1
#author:linkscue@gmail.com
#example:./unpack-exynos-boot.sh recovery.img

if [[ $# == 0 ]]; then
    echo "usage: `basename $0` \$boot.img"
    exit 1
fi

mkimage=../linkscue-scripts/bootimg-scripts-exynos/mkimage
mkbootimg=../linkscue-scripts/bootimg-scripts-common/mkbootimg
bootimg=../linkscue-scripts/bootimg-scripts-common/bootimg.py

img=$1
tmp=tmp_$$.txt

echo "1) unpack $img"
$bootimg --unpack-bootimg $img 2> $tmp

echo "2) write output param"
array=( base cmdline page_size padding_size )
for param in ${array[@]}; do
    #statements
    cat $tmp | grep $param | awk -F'=' '{print $2}' > $img-$param
done

echo "3) skip 64 bytes of the ramdisk head, and get load address"
dd if=ramdisk of=ramdisk.gz bs=$((16*4)) skip=1
echo $(file ramdisk | sed 's/,/\n/g' | sed -n 's/ Load Address: //p') > $img-rdloadaddr

echo "4) unpack ramdisk.gz"
$bootimg --unpack-ramdisk ramdisk.gz

rm -f $tmp
