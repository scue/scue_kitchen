#!/bin/bash
# Version: 0.1
# Author: linkscue
# E-mail: linkscue@gmail.com

# please modify the under line to match your machine
sign_dir=$(dirname $0)/cmsign

if [[ $# = 1 || $# = 2 ]]; then
    if [[ $2 ]]; then
        signed_zip=$2
    else 
        signed_zip=${1%.*}_Signed.zip
    fi
    java -jar $sign_dir/signapk.jar -w $sign_dir/testkey.x509.pem $sign_dir/testkey.pk8 $1 $signed_zip
    echo "I: Signed lenovo k860 zip is $signed_zip."
else
    echo 'usage: cmsign $unsign_zip $signed_zip'
    exit 1
fi

