#!/bin/bash
# 这是一个普通程序签名脚本

dir=$(dirname $0)
jar="$dir"/signapk.jar 
pem="$dir"/testkey.x509.pem
pk8="$dir"/testkey.pk8
apk=$1
apkname=${apk%.*}
apksigned="$apkname"_Signed
zip_true=$(echo $1 | grep zip)
if [[ $zip_true ]]; then
    output=$apksigned.zip
else
    output=$apksigned.apk
fi
java -jar $jar $pem $pk8 $apk $output
echo "I: signed file is $output"

