Translate the page if you are not familiar with the language.
厨房版本：0.5 beta
厨房作者：linkscue@gmail.com
权利声明：本程序开源开放，任何人可以复制修改，并重新发布，但需保留原作者信息；
项目地址：git@github.com:scue/scue_kitchen.git

主要功能：
1. 为boot.img添加root、busybox及init.d支持；
2. 一键制作农历锁屏；
3. 一键制作全局透明；
4. 清理已移除程序残留的非必需库文件；
5. 解压华为UPDATE.APP文件(海思、MTK平台将支持精确解压)；
6. 轻松制作华为data大小分区卡刷包；
7. 轻松合并odex与分离odex
8. 联想官方升级包szb格式制作；
9. 签名工具，支持签名系统应用程序；

环境要求：
!. 不能在Cygwin中操作!
1. 64位要安装32位运行组件：在终端上输入 "sudo apt-get install ia32-libs"
2. 64位自动配置java环境(Linux_java_env.zip)：http://pan.baidu.com/share/link?shareid=322603&uk=1175777033

操作说明：
1. 打开终端程序，使用cd命令打开至此文件夹；
2. 在终端程序上输入 "sudo chmod 755 scue_kitchen.sh"
3. 然后在终端程序上输入 "./scue_kitchen.sh"  #(请注意不要少了./这两个字符)


更新历史：
>> 0.5 beta1
1. 主菜单中添加“99) 直接制作成zip卡刷包；”
注:可以制作完成后，可以自行添加boot.img recovery.img至zip卡刷包中(无须修改升级脚本)

>> 0.4 稳定发行版
1. 重写支持部分华为机型的UPDATE.app精确解压
2. 重写联想手机固件的szb制作工具szbtool
3. 优化三星平台boot.img的解压与打包

>> 0.3 beta2
1. 分离odex时，支持选择设备（方便多台设备连接时的操作）
2. 在厨房界面的boot.img菜单上添加高级菜单，支持荣耀2海思平台boot.img解压，及增强版解压boot.img工具；

>> 0.3 beta1
1. 更新绝对路径获取方法，确保在任何一个地方都能运行此厨房；
2. 修正一键制作农历锁屏会删除原始jar文件的问题；
3. 修复一键制作农历锁屏jar_new目录有文件时不能覆盖的问题；
4. 开始支持合并jar与odex，同样，只需把apk或jar与odex文件放置于odex_dir目录即可，输出目录在工作目录的new下；

>> 0.2 
1. 加入了联想特殊szb格式文件的处理；
2. 完善了主菜单所有的功能；
3. 操作界面的细节重新排版；

>> 0.1 beta5
1. 修复引用文件不正确的bug; 
2. 添加“环境要求”说明及自动配置java环境脚本；
3. 除联想szb格式还在构思以外，其他功能已全部实现，并使用新的Ubuntu虚拟机验证通过； #^_^#

>> 0.1 beta4
1. 修复制作全局透明背景时，签名文件丢失的问题；
2. 修改主界面显示内容

>> 0.1 beta3
1.目前实现了8项主菜单功能(联想szb格式还在构思)；
2.其中实现合并odex和apk是比较好的一种方法，如果其他方法合并失败，不防试试这个厨房；

>> 0.1 beta2
修正bootimg选项中打包的错误；

>> 0.1 beta1
目录仅支持主菜单的前5个选项的功能；

