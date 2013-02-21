#!/bin/bash
# 这是一个系统程序签名脚本

dir=$(dirname $0)
jar="$dir"/signapk.jar 
pem="$dir"/platform.x509.pem
pk8="$dir"/platform.pk8
apk=$1
apkname=${apk%.*}
apksigned="$apkname"_Signed
output=${2:-"$apksigned.apk"}
java -jar $jar $pem $pk8 $apk $output
echo "I: signed file is $output"
