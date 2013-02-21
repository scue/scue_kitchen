#!/bin/bash

#self
script_self=$(readlink -f $0)
dir_self=$(dirname $script_self)

kernel=$1
rd_dir=$2
outfile=${3:-boot_$$.img}
array=( base cmdline page_size padding_size rdloadaddr )
base=$(cat $(ls | grep "\-base"))
cmdline=$(cat $(ls | grep "\-cmdline"))
page_size=$(cat $(ls | grep "\-page_size"))
padding_size=$(cat $(ls | grep "\-padding_size"))
rdloadaddr=$(cat $(ls | grep "\-rdloadaddr"))
mkimage=$dir_self/mkimage
mkbootimg=$dir_self/mkbootimg

#制作ramdisk
if [[ ! -d $rd_dir ]]; then
    echo "E: can't find $rd_dir!"
    exit 2
fi
cd $rd_dir 
find . | cpio -o -H newc | gzip > ../ramdisk_$$.gz
cd ../
$mkimage -A arm -O linux -T ramdisk -C none -a $rdloadaddr -n "ramdisk" -d ramdisk_$$.gz ramdisk.cpio.gz

#制作boot.img
$mkbootimg --kernel $kernel --ramdisk ramdisk.cpio.gz --base $base --cmdline \'$cmdline\' --pagesize $page_size -o $outfile
echo "I: the output file is $outfile"
