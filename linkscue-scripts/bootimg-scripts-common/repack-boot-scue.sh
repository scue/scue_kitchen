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
mkbootimg=$dir_self/mkbootimg

cd $rd_dir 
find . | cpio -o -H newc | gzip > ../ramdisk.cpio.gz
cd ../

#制作boot.img
$mkbootimg --kernel $kernel --ramdisk ramdisk.cpio.gz --base $base --cmdline \'$cmdline\' --pagesize $page_size -o $outfile
echo "I: the output file is $outfile"
