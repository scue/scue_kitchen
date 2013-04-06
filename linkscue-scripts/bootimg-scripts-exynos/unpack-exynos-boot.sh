#!/bin/bash
#version:0.1
#author:linkscue@gmail.com
#example:./unpack-exynos-boot.sh recovery.img

#self
script_self=$(readlink -f $0)
TOPDIR=${script_self%/linkscue-scripts/bootimg-scripts-exynos/unpack-exynos-boot.sh}

mkimage=$TOPDIR/linkscue-scripts/bootimg-scripts-exynos/mkimage
mkbootimg=$TOPDIR/linkscue-scripts/bootimg-scripts-common/mkbootimg
bootimg=$TOPDIR/linkscue-scripts/bootimg-scripts-common/bootimg.py

img=$1
tmp=tmp_$$.txt

echo "1) unpack $img"
$bootimg --unpack-bootimg $img 2> $tmp

echo "2) write output param"
array=( base cmdline page_size padding_size )
for param in ${array[@]}; do
    cat $tmp | grep $param | awk -F'=' '{print $2}' | sed 's/"//g' > $img-$param # 双引号"不应该被获取
done

echo "3) skip 64 bytes of the ramdisk head, and get load address"
dd if=ramdisk of=ramdisk.gz bs=$((16*4)) skip=1
echo $(file ramdisk | sed 's/,/\n/g' | sed -n 's/ Load Address: //p') > $img-rdloadaddr

echo "4) unpack ramdisk.gz"
$bootimg --unpack-ramdisk ramdisk.gz

rm -f $tmp
