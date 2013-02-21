#!/bin/bash

#self
script_self=$(readlink -f $0)

#顶级目录
TOPDIR=${script_self%/linkscue-scripts/menu_scripts/menu_szb.sh}
scripts_dir=$TOPDIR/linkscue-scripts
sub_menu_dir=$scripts_dir/menu_scripts

#工作目录
wd=$1
szb=$2
oldwd=$(pwd)
szbtool_dir=$scripts_dir/lenovo_szbtool
szbtool=$szbtool_dir/leszb
unpack_szb=$szbtool_dir/unpackszb.py
repack_szb=$szbtool_dir/repack_szb.sh
unpack_img=$szbtool_dir/unpack_img.sh
repack_img=$szbtool_dir/repack_img.sh
make_ext4fs_jb=$scripts_dir/make_ext4fs_jb/make_ext4fs
make_ext4fs_ics=$scripts_dir/make_ext4fs_ics/make_ext4fs
simg2img=$scripts_dir/make_ext4fs_ics/simg2img

#初始化
clear
echo ""
echo "欢迎使用linkscue szb定制厨房工具(感谢木马男孩szb工具)！"
echo ""
echo "使用说明："
echo ""
echo "1. 把需要解压的szb文件放置于 $(basename $wd)/"
echo "2. 解压szb输出的img文件放置于 $(basename $wd)/images_output/"
echo "3. 打包img输出的img文件放置于 $(basename $wd)/images_repack/"
echo "4. 本工具涉及挂载取出img内文件将需root权限"
echo ""
echo "功能菜单:"
echo ""
echo " 1) 解压szb文件；"
echo " 2) 解压img文件；"
echo " 3) 打包img文件；"
echo " 4) 打包szb文件；"
echo " 5) 验证szb文件；"
echo " 6) 移除system的链接文件(zip卡刷包必选)；"
echo " b) 返回主菜单；"
echo ""

#获取szb文件列表
list_szb="$(ls -1 $wd/*.szb 2> /dev/null | grep "\.szb$" )" 
list_szb2="$(ls -1 $wd/*.szb 2> /dev/null | grep "\.szb$";echo "手动输入";echo "自动生成")" 
preload=$wd/images_output/preload.img
system=$wd/images_output/system.img
preload_out=$wd/images_output/preload_out.img
system_out=$wd/images_output/system_out.img
tmp=$wd/images_output/tmp_$$
detect_p=$(file $preload | awk -F': ' '{print $2}')
detect_s=$(file $system  | awk -F': ' '{print $2}')

#获取选项
read -p "请输入选项:" opt
echo ""
case $opt in
1)  #解压szb选项
    #错误侦测
    while [[ "$list_szb" == "" ]]; do
        echo ""
        read -p "请把szb文件放置于$(basename $wd)/目录下:"
        list_szb="$(ls -1 $wd/*.szb 2> /dev/null | grep "\.szb$" )"
    done
    echo ""
    echo "请选择您要解压的szb文件："
    select szb in ${list_szb[@]};do
        echo ""
        echo "您选择将要解压szb文件是$(basename $szb)"
        break;
    done;
    #解压前清除原来的img文件
    rm -rf $wd/images_output/*.img
    #执行解压操作
    $unpack_szb $szb $wd/images_output/
    echo ""
    echo "$(basename $szb)解压已完成，输出目录是$(basename $wd)/images_output/"
    echo ""
    read -p "请按任意键返回:"
    $script_self $wd $szb
;;
2)  #解压img选项
    #检查images_output是否为空
    detect_empty=$(ls -1 $wd/images_output/*.img)
    if [[ "$detect_empty" == "" ]]; then
        echo "发现上次解压[ $(basename $szb) ]未输出img文件；"
        echo ""
        read -p "请按任意键返回:"
    $script_self $wd $szb
    fi
    mkdir -p $tmp
    #获取szb文件名,并指定preload、system存放的目录；
    if [[ "$szb" == "" ]]; then
        echo "希望指定img的来源文件方便区分不同的镜像，请选择:"
        select szb in ${list_szb2[@]};do
            break;
        done;
        case $szb in
             "手动输入") 
                read -p "请输入szb文件名[不要有空格]: " szb 
                if [[ "$szb" != "" ]]; then
                    preload_dir=$wd/"${szb%.szb}"_preload
                    system_dir=$wd/"${szb%.szb}"_system
                fi
             ;;
             "自动生成")
                preload_dir=$wd/`date +"%Y%m%d_%H%M%S"`_preload
                system_dir=$wd/`date +"%Y%m%d_%H%M%S"`_system
             ;;
             *)
                echo ""
                echo "您选择img来源的szb文件是$(basename $szb)" 
                preload_dir="${szb%.szb}"_preload
                system_dir="${szb%.szb}"_system
             ;;
        esac
      
    else
        #已由菜单1返回szb文件名时
        preload_dir="${szb%.szb}"_preload
        system_dir="${szb%.szb}"_system
        echo "刚刚解压的szb文件是:$szb"
    fi
    echo ""
    echo "此子菜单暂时只支持解压preload与system两分区，且提取img分区需root权限；"
    echo ""
    sudo ls > /dev/null
    echo ""
    echo "正在解压preload分区"   
    if [[ "$detect_p" == "data" ]]; then
        echo -n "正解压缩："
        $simg2img $preload $preload_out
    else
        mv $preload $preload_out
    fi
    sudo mount $preload_out $tmp 2> /dev/null
    sudo chown -R $USER $tmp
    sudo chmod -R 775 $tmp
    echo "正在拷贝preload分区文件至 $(basename $wd)/$(basename $preload_dir) .."
    rm -rf ${preload_dir}_bak 2> /dev/null
    mv -f $preload_dir ${preload_dir}_bak 2> /dev/null
    cp -af $tmp $preload_dir
    sudo umount $tmp 2> /dev/null
    echo ""
    echo "正在解压system分区"   
    if [[ "$detect_p" == "data" ]]; then
        echo -n "正解压缩："
        $simg2img $system $system_out
    else
        mv $system $system_out
    fi
    sudo mount $system_out $tmp 2> /dev/null
    sudo chown -R $USER $tmp
    sudo chmod -R 775 $tmp
    echo "正在拷贝system分区文件至 $(basename $wd)/$(basename $system_dir) .."
    rm -rf ${system_dir}_bak 2> /dev/null
    mv -f $system_dir ${system_dir}_bak 2> /dev/null
    cp -af $tmp $system_dir
    sudo umount $tmp 2> /dev/null
    rm -rf $tmp
    mv $preload_out $preload
    mv $system_out $system
    echo ""
    echo "解压img文件完毕，如需解压boot.img、recovery.img请使用其他子菜单功能"
    echo ""
    read -p "请按任意键返回:"
    $script_self $wd 
;;
3)  #打包img选项
    #目录列表,并备份已打包的旧的img
    list_system=$(find $wd -name "*system"; echo "don't_repack!")
    list_preload=$(find $wd -name "*preload"; echo "don't_repack!")
    #选择要打包的system目录；
    echo "选择需打包的system目录: "
    select repack_system_dir in ${list_system[@]};do
        break;
    done
    #选择要打包的preload目录；
    echo ""
    echo "选择需打包的preload目录: "
    select repack_preload_dir in ${list_preload[@]};do
        break;
    done
    #判定是否要打包system目录
    if [[ "$repack_system_dir" != "don't_repack!" ]]; then
        #判定system系统版本，4.0、4.1的img打包方法是不相同的；
        ics_true=$(sed -n "/ro.build.description/{/4.0/=}" $repack_system_dir/build.prop)
        if [[ -f $wd/images_repack/system.img ]]; then
            echo ""
            echo "正在备份上次打包好的$wd/images_repack/system.img .."
            mv $wd/images_repack/system.img $wd/images_repack/system.img.bak
        fi
        echo ""
        if [[ "$ics_true" != "" ]]; then
            echo "正在制作ICS版本的system.img .."
            $make_ext4fs_jb  -s -l 400M -a system $wd/images_repack/system.img $repack_system_dir
        else
            echo "正在制作JB版本的system.img .."
            $make_ext4fs_ics -s -l 400M -a system $wd/images_repack/system.img $repack_system_dir
        fi
    fi
    #判定是否要打包preload目录
    if [[ "$repack_preload_dir" != "don't_repack!" ]]; then
        #4.0、4.1的preload.img打包方法是相同的；
        ics_true=1
        if [[ -f $wd/images_repack/preload.img ]]; then
            echo ""
            echo "正在备份上次打包好的$wd/images_repack/preload.img .."
            mv $wd/images_repack/preload.img $wd/images_repack/preload.img.bak
        fi
        echo ""
        if [[ "$ics_true" != "" ]]; then
            echo "正在制作ICS版本的preload.img .."
            $make_ext4fs_jb  -s -l 199M -a preload $wd/images_repack/preload.img $repack_preload_dir
        else
            echo "正在制作JB版本的preload.img .."
            $make_ext4fs_ics -s -l 199M -a preload $wd/images_repack/preload.img $repack_preload_dir
        fi
    fi
    echo ""
    echo "制作img文件已完成，输出文件在 $(basename $wd)/images_repack/"
    echo ""
    read -p "请按任意键返回:"
    $script_self $wd
;;
4)  #打包为szb文件；
    #创建目录
    mkdir -p $wd/szb_repack
    repack_cmd=/tmp/repack_szb_cmd_$$.txt
    echo -n $szbtool > $repack_cmd
    echo -n " -a $USER@$HOSTNAME" >> $repack_cmd
    echo "重要说明："
    echo "1. 通常只需放置boot.img、system.img和preload.img这两个文件即可；"
    echo "2. 如果szb_repack目录加入uboot.bin文件将可能会对手机内存重新分区；"
    echo "3. 加入uboot.bin时请务必把boot.img、recovery.img、cpimage.img一起加入szb_repack目录；"
    echo "4. 暂时不能添加清除data、清除cache的功能；"
    echo ""
    echo "把uboot.bin boot.img recovery.img cpimage.img system.img preload.img"
    echo "等文件放置于 $(basename $wd)/szb_repack/目录下，注意文件名；"
    echo ""
    read -p "以上操作完成后，按任意键以继续: "
    echo ""
    list_images=$(find $wd/szb_repack/*)
    for n in ${list_images[@]}; do
        img_file=$(basename $n)
        case $img_file in
            uboot.bin)      echo -n " -b uboot.bin" >> $repack_cmd ;;
            boot.img)       echo -n " -k boot.img" >> $repack_cmd ;;
            system.img)     echo -n " -s system.img" >> $repack_cmd ;;
            cpimage.img)    echo -n " -c cpimage.img" >> $repack_cmd ;;
            preload.img)    echo -n " -p preload.img" >> $repack_cmd ;;
            recovery.img)   echo -n " -y recovery.img" >> $repack_cmd ;;
        esac
    done
    read -p "请输入szb固件名称[不要有空格]: " szb_name
    szb_name_repack="${szb_name%.szb}"
    szb_name_output=${szb_name_repack}.szb
    echo -n " -v $szb_name_repack" >> $repack_cmd
    echo ""
    echo "正在打包为szb文件，其中打包过程可能会比较长 .."
    cd $wd/szb_repack/
    $(cat $repack_cmd)
    mv $szb_name_repack $szb_name_output
    rm -f $repack_cmd
    cd $oldwd
    echo ""
    echo "szb打包工作已经完成，输出文件在 $wd/szb_repack/$szb_name_output"
    echo ""
    read -p "请按任意键返回:"
    $script_self $wd
;;
5)  #验证szb的正确性；
    #错误侦测
    while [[ "$list_szb" == "" ]]; do
        echo ""
        read -p "请把szb文件放置于$(basename $wd)/目录下:"
    done
    echo ""
    echo "请选择您要解压的szb文件："
    select szb in ${list_szb[@]};do
        echo ""
        echo "您选择将要解压szb文件是$(basename $szb)"
        break;
    done;
    $szbtool -i $szb
    echo ""
    read -p "请按任意键返回:"
    $script_self $wd
;;
6)  #清除链接文件以打包为zip
    #目录列表
    echo ""
    echo "**如果你制作szb刷机包，不需要清理链接文件，这个选项为制作zip卡刷包准备的**"
    echo ""
    list_system2=$(find $wd -name "*system"; echo "算了，我不制作zip卡刷包..")
    echo ""
    echo "选择需删除链接文件的system目录: "
    select rml_system_dir in ${list_system2[@]};do
        break;
    done
    if [[ $rml_system_dir != "算了，我不制作zip卡刷包.." ]]; then
        find $rml_system_dir -type l > $wd/remove_link_file.txt
        find $rml_system_dir -type l -exec rm -rf {} {} \;
        echo ""
        echo "$(basename $rml_system_dir) 目录内的链接文件已被清理；"
        echo ""
        echo "注意：清理链接文件只为了能通过zip签名，但卡刷包的升级脚本中应当加入这些链接文件;"

    fi
    echo ""
    read -p "请按任意键返回:"
    $script_self $wd
;;
b)
$TOPDIR/scue_kitchen.sh
;;
*)
    $script_self $wd $szb
;;
esac
