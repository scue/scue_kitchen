#!/bin/bash
# Version: 0.3
# Author: linkscue
# this is a script to merge a changed DIR to a System Apk
if [[ $# -lt 2 ]]; then
    echo "Usage: `basename $0` -arRdA \$DIR \$NEW_APK"
    echo "[OPTIONS]
    -r merge resources.arsc file
    -R merge res/ diretory all files 
    -d merge classes.dex file
    -A merge AndroidManifest.xml
    -a merge all above files"
    exit 1
fi
#self
script_self=$(readlink -f $0)
#dir
TOPDIR=${script_self%/linkscue-scripts/apktool/mergeapk.sh}
scripts_dir=$TOPDIR/linkscue-scripts
sub_menu_dir=$scripts_dir/menu_scripts
zipalign=$TOPDIR/linkscue-scripts/zipalign
merge_apk=$scripts_dir/apktool/mergeapk.sh
apktool=$scripts_dir/apktool/apktool

DIR=$2
FILE=$3
TMPDIR=${DIR}_$$
if [[ $DIR ]]; then
    $apktool b $DIR $FILE 
    if [[ $? != 0 ]]; then
        echo "I: can't find apktool command!"
        exit 1
    else
        if [[ -f "$DIR".apk ]]; then
            unzip "$DIR".apk -d $TMPDIR > /dev/null;
            #get which file will be cp 
            while getopts arRdA option;do
            case $option
                in
                   a) echo "I:merge all files .."
                      rm -rf $TMPDIR/res/
                      cp -a $DIR/build/apk/res $TMPDIR/res
                      cp $DIR/build/apk/resources.arsc $TMPDIR/resources.arsc
                      cp $DIR/build/apk/classes.dex $TMPDIR/classes.dex &> /dev/null
                      cp $DIR/build/apk/AndroidManifest.xml $TMPDIR/AndroidManifest.xml
                      ;;
                   r) echo "I:merge resources.arsc .."
                      cp $DIR/build/apk/resources.arsc $TMPDIR/resources.arsc
                      ;;
                   R) echo "I:merge res diretory .."
                      rm -rf $TMPDIR/res/
                      cp -a $DIR/build/apk/res $TMPDIR/res
                      ;;
                   d) echo "I:merge classes.dex .."
                      cp $DIR/build/apk/classes.dex $TMPDIR/classes.dex &> /dev/null
                      ;;
                   A) echo "I:merge AndroidManifest.xml .."
                      cp $DIR/build/apk/AndroidManifest.xml $TMPDIR/AndroidManifest.xml
                      ;;
                   /?) cp $DIR/build/apk/resources.arsc $TMPDIR/resources.arsc
                       ;;
                esac
            done
            cp $DIR/build/apk/resources.arsc $TMPDIR/resources.arsc
            cd $TMPDIR
            zip -r1 1.apk ./* > /dev/null
            $zipalign -vf 4 1.apk $FILE
            cd ../
            rm -rf $TMPDIR
        else 
            echo "I: can't find $DIR.apk! "
            exit 1
        fi
    fi
else 
    echo "I: can't find $DIR diretory!"
    exit 1
fi
echo "I: the new system apk is $FILE."
