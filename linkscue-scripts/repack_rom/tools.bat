
::关闭回显功能；
@echo off

::清除屏幕信息；
cls

::修改窗口标题；
title 华为手机固件制作集成工具箱

::修改显示颜色；
color 2

::开始进入操作界面；
echo ===============================================================
echo           欢迎使用华为手机固件制作集成工具箱
echo                                   版本：0.12
echo                                   作者：linkscue
echo ===============================================================
echo.
echo 准备工作
echo   1. 手机已ROOT；
echo   2. 手机打开USB调试；
echo   3. 手机正常开机状态下连接至电脑；
echo   4. 电脑端安装好驱动程序并能正确连接手机；
echo. 

::检测是否能正确连接手机，并设置好相应的权限；
echo 正在检测adb是否能正确连接手机..
adb shell 'su -c chmod 777 -R /data/local/tmp' >nul 
set error_number=%errorlevel%
IF NOT %error_number% == 0 goto error_report

::开始上传必须的工具至手机
adb push tools\META-INF /data/local/tmp/META-INF 2>nul
adb push tools\busybox /data/local/tmp/busybox 2>nul
adb push tools\backup_rom.sh /data/local/tmp/backup_rom.sh 2>nul 
adb push tools\mount_data.sh /data/local/tmp/mount_data.sh 2>nul 
adb push tools\restore_rom.sh /data/local/tmp/restore_rom.sh 2>nul
adb push tools\zip /data/local/tmp/zip 2>nul
set error_number=%errorlevel%
IF NOT %error_number% == 0 goto error_report
adb shell < tools\tools_permissions >nul
echo 手机正常连接。
adb shell su -c /data/local/tmp/backup_rom.sh
goto erase

::错误反馈标签
:error_report
color C
echo 操作失败，错误代码: %error_number%
echo.
goto exit

::清除文件
:erase
adb shell < tools\tools_erase >nul
goto exit

::退出标签
:exit
echo.
color 6
pause