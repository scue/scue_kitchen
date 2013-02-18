#!/bin/bash
# Version: 0.1
# Author: linkscue
# E-mail: linkscue@gmail.com
# Put what apks you want to remove to rm_app or delapp dir;
# Or you can also add a diretory to dir_array, Enjoy!
lib_dir=lib
dir_array=(\
 ./rm_app\
 ./delapp\
)

if [[ ! -d $lib_dir ]]; then
    echo "I: can't find $lib_dir!"
    exit 1
else 
    if [[ -e rm_lib_list.txt ]]; then
        rm -vf rm_lib_list.txt
    fi
    for x in ${dir_array[@]};do 
        if [[ -d $x ]]; then
            ls -1 $x > rm_app_list.txt
            cat rm_app_list.txt | while read line
            do 
                echo "I: rm $line's lib.. " 
                unzip -l $x/$line | awk '{print $4}' | grep ^lib | awk -F'/' '{print $3}' \
                >> rm_lib_list.txt
            done
            
        fi
    done
    cat rm_lib_list.txt | while read lib_line
    do
        rm -f $lib_dir/$lib_line &> /dev/null
    done
fi
