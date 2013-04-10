#!/bin/bash
script_self=$(readlink -f $0)
TOPDIR=${script_self%/linkscue-scripts/menu_scripts/menu_author.sh}
clear
echo ""
echo "欢迎使用linkscue ROM定制厨房工具！"
echo "
版本：0.5 beta1
作者：linkscue@gmail.com
声明：本程序开源开放，任何人可以复制、修改并重新发布，但请保留原作者信息；

环境要求：
1. 64位要安装32位运行组件：在终端上输入 "sudo apt-get install ia32-libs"
2. 自动配置java环境(Linux_java_env.zip)：http://pan.baidu.com/share/link?shareid=322603&uk=1175777033

操作说明：
1. 打开终端程序，使用cd命令打开至此文件夹；
2. 在终端程序上输入 "sudo chmod 755 scue_kitchen.sh"
3. 然后在终端程序上输入 "./scue_kitchen.sh"  #(请注意不要少了./这两个字符)
"
echo ""
read -p "请按任意键返回主菜单:"
$TOPDIR/scue_kitchen.sh
