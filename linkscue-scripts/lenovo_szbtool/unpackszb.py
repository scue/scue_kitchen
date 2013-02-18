#!/usr/bin/python
# -*- coding: utf-8 -*-
# Version: 0.2
# Author: linkscue
# Website: http://bbs.lephone.cc/forum-67-1.html

import os
import sys
import time

print 'Usage: unpackszb [file] [diretory] [padding]'

# 判断从Shell获得要提取的文件名称，为空时退出
try:
    sys.argv[1]
except IndexError:
       sys.exit();

# 判断从Shell得到的目录，若无则默认解压到当前目录
try:
    sys.argv[2]
except IndexError:
       extrPath='.'
else:
    extrPath=sys.argv[2];
      
# 判断从Shell得到的附加偏移，若无则默认偏移量为0
try:
    sys.argv[3]
except IndexError:
        padding=0
else:
    padding=sys.argv[3];


print 'File: %s' %(sys.argv[1])
print 'Diretory: %s' %(extrPath)
print 'Padding: %d bytes' %(padding)

# 判断解压的目录是否存在，不存在则创建
if os.path.exists(extrPath)==0:
    os.mkdir(extrPath,0755);

# 开始逐字节读取文件，存入cont当中
f=open(sys.argv[1],'rb')
cont=f.read()
f.close()

# getAddr函数获取得镜像首址、尾址、镜像名称、镜像大小
def getAddr(addr):
    temp=cont[addr+8:addr+12]
    # 计算首地址,把十六进制表示的Addr，转换成ASCII码256=16×16；
    head=ord(temp[0])+ord(temp[1])*256+ord(temp[2])*256*256+ord(temp[3])*256*256*256
    temp=cont[addr+12:addr+16]
    # 计算image的大小，把十六进制表示的Addr，转换成ASCII码256=16×16；
    size=ord(temp[0])+ord(temp[1])*256+ord(temp[2])*256*256+ord(temp[3])*256*256*256
    # 计算末地址，把Head和Size相加即可；
    tail=head+size+padding;
    # 名字的获取经由addr，往上退回0x60十六进制地址得到
    imageName=cont[addr-0x60:addr-0x60+0xf]
    # 把右边多余的字符串剪切掉
    imageName=imageName.rstrip(chr(0x00))
    imageSize=tail-head;
    return (head,tail,imageName,imageSize);

# writeImg把首尾地址的镜像，写入到命令中指定的目录
def writeImg(head,tail,imageName):
    temp=cont[head:tail];
    fileName=extrPath+'/'+imageName;
    #判断是否有同名文件存在，若有则直接删除旧的文件(文件大且源文件存在，备份不是很有必要)
    if os.path.exists(fileName):
        os.remove(fileName)
    f2=open(fileName,'wb')
    f2.write(temp)
    f2.close()

# 主函数
if __name__=='__main__':
    addrList=[0x160,0x260,0x360,0x460,0x560,0x660,0x760,0x860,0x960]
    for i in addrList:
        [head,tail,imageName,imageSize]=getAddr(i)
        # 判断截取得到的image文件的位置是否为空，空时不做处理
        if head!=0:
            print 'Unpacking [%-13s], marker: 0x%04x, from: 0x%08x~0x%08x, size:[%12s]'\
            %(imageName,i,head,tail,format(imageSize,','));
            writeImg(head,tail,imageName)
    print 'All Done!',time.strftime('%Y-%m-%d %H:%M:%S')
