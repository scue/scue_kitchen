#!/usr/bin/python
# Version: 0.1
# Author: linkscue
# Function: unpack any hauwei devices UPDATE.APP 
# Thanks to McSpoon(zhaoxing-go@163.com)

import os
import sys
import struct

print 'Usage: unpack $huawei_app_file'
try:
    sys.argv[1]
except IndexError:
        File="UPDATE.APP"
else:
    File=sys.argv[1];

verify_code=0xa55aaa55
verify_bin=struct.pack("I",verify_code)

print "I: unpack",File
f=open(File,'rb')
cont=f.read()
f.close()

start=0
sub_file=1
search=verify_bin
while True:
    index = cont.find(search, start)
    if index == -1:
        break
    packet_addr=cont[index+4:index+8]
    data_addr=cont[index+24:index+28]
    packet_size_tuple=struct.unpack("I",packet_addr)
    data_size_tuple=struct.unpack("I",data_addr)
    packet_size=int(reduce(lambda rst, d: rst * 10 + d, packet_size_tuple))
    data_size=int(reduce(lambda rst, d: rst * 10 + d, data_size_tuple))
    temp=cont[index+packet_size:index+packet_size+data_size]
    filename='out_'+str(sub_file)+'.img'
    f1=open(filename,'wb')
    f1.write(temp)
    f1.close()
    print( "I: verify code found at: 0x%08x, size: %10d bytes, unpack to --> %-20s" \
    % (index,data_size, filename) )
    start = index + 1
    sub_file += 1
