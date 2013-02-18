#!/bin/bash
# Version: 0.3
# Author: linkscue
# E-mail: linkscue@gmail.com

# function: get key words start line number,$1=key_word
get_start_line(){
    # shell function can't return >255 value, so echo replace return
    #echo $(grep -n "$1" $style_file | awk -F':' '{print $1}')
    echo $(sed -n "/$1/{=;q}" $style_file )
}

# function: get a style(or sub_style) end line number,$1=line_number
get_end_line(){
    echo $(sed -n  "$1,/<\/style>/{=}" $style_file | sed -n '$p')
}

# function: get pattern line number,s1=start s2=end s3=pattern
get_pattern_line(){
    echo $(sed -n -e "$1,$2{/$3/{=;q}}" $style_file)
}

#function: get a style start and end line number
get_start_end_line(){
    echo $(get_start_line "$1")
    echo $(get_end_line $(get_start_line "$1") )
}

#错误侦测
if [[ $# != 2 ]]; then
    #statements
    echo 'usage: change_xml $style_file $color_file '
    exit 1
fi

#全局透明将修改的文件
style_file=$1
color_file=$2
#style_file=styles.xml
#color_file=colors.xml

#指定要修改的主题，也是索引的关键词
theme_main_key='<style name="Theme">'
theme_black_key='<style name="Theme.Black'
holo_main_key='<style name="Theme.Holo"'
holo_light_key='<style name="Theme.Holo.Light"'
holo_dialog_key='<style name="Theme.Holo.Dialog"'
holo_panel_key='<style name="Theme.Holo.Panel"'
holo_input_key='<style name="Theme.Holo.InputMethod"'

#获取将要修改的主题的起始、终止位置
theme_main_pos=$(get_start_end_line "$theme_main_key")
theme_black_pos=$(get_start_end_line "$theme_black_key")
holo_main_pos=$(get_start_end_line "$holo_main_key")
holo_light_pos=$(get_start_end_line "$holo_light_key")
holo_dialog_pos=$(get_start_end_line "$holo_dialog_key")
holo_panel_pos=$(get_start_end_line "$holo_panel_key")
holo_input_pos=$(get_start_end_line "$holo_input_key")

#打印已修改位置
printf "changed start: %4d, end: %4d\n" $theme_main_pos
printf "changed start: %4d, end: %4d\n" $theme_black_pos
printf "changed start: %4d, end: %4d\n" $holo_main_pos
printf "changed start: %4d, end: %4d\n" $holo_light_pos
printf "changed start: %4d, end: %4d\n" $holo_dialog_pos
printf "changed start: %4d, end: %4d\n" $holo_panel_pos
printf "changed start: %4d, end: %4d\n" $holo_input_pos


#获取要修改位置的精确行位置；
theme_main_background=$(get_pattern_line $theme_main_pos windowBackground)
theme_black_background=$(get_pattern_line $theme_black_pos windowBackground)
holo_main_background=$(get_pattern_line $holo_main_pos colorBackground)
holo_main_show_wp=$(get_pattern_line $holo_main_pos windowShowWallpaper)
holo_light_show_wp=$(get_pattern_line $holo_light_pos windowShowWallpaper)
holo_dialog_show_wp=$(get_pattern_line $holo_dialog_pos windowShowWallpaper)
holo_panel_show_wp=$(get_pattern_line $holo_panel_pos windowShowWallpaper)
holo_input_show_wp=$(get_pattern_line $holo_input_pos windowShowWallpaper)

#一些主题样式
text_fSwp='       <item name=\"windowShowWallpaper\">false</item>'
text_tSwp='       <item name=\"windowShowWallpaper\">true</item>'
text_cBgd_clr='   <color name=\"background\">\#c8000000<\/color>'
text_bBgd_add='       <item name="windowBackground">@color/background</item>'
text_bBgd_or='drawable\/screen_background_selector_dark'
text_bBgd_new='color\/background'
text_cBgd_or='background_holo_dark'
text_cBgd_new='transparent'

# change the style file
a=1; b=1;
sed "$theme_main_background{s/$text_bBgd_or/$text_bBgd_new/}" $style_file > $b.xml;a=$b;((b++));
sed "$holo_main_background{s/$text_cBgd_or/$text_cBgd_new/}" $a.xml > $b.xml;a=$b;((b++));
sed "$holo_main_show_wp c\ $text_tSwp" $a.xml > $b.xml;a=$b;((b++));
if [[ $holo_light_show_wp ]]; then
    sed "$holo_light_show_wp c\ $text_fSwp" $a.xml > $b.xml;a=$b;((b++));
else 
    sed "$(echo $holo_light_pos | awk '{print $2}') i\ $text_fSwp" $a.xml > $b.xml;a=$b;((b++));
fi
if [[ $holo_dialog_show_wp ]]; then
    sed "$holo_dialog_show_wp c\ $text_fSwp" $a.xml > $b.xml;a=$b;((b++));
else 
    sed "$(echo $holo_dialog_pos | awk '{print $2}') i\ $text_fSwp" $a.xml > $b.xml;a=$b;((b++));
fi
if [[ $holo_panel_show_wp ]]; then
    sed "$holo_panel_show_wp c\ $text_fSwp" $a.xml > $b.xml;a=$b;((b++));
else 
    sed "$(echo $holo_panel_pos | awk '{print $2}') i\ $text_fSwp" $a.xml > $b.xml;a=$b;((b++));
fi
if [[ $holo_input_show_wp ]]; then
    sed "$holo_input_show_wp c\ $text_fSwp" $a.xml > $b.xml;a=$b;((b++));
else 
    sed "$(echo $holo_input_pos | awk '{print $2}') i\ $text_fSwp" $a.xml > $b.xml;a=$b;((b++));
fi
sed "$holo_main_background i\ $text_bBgd_add" $a.xml > $b.xml;a=$b;((b++));
sed "7 i\ $text_cBgd_clr" $color_file > color_new.xml

# replace/rm file
cp $a.xml style_new.xml
mv style_new.xml $style_file
mv color_new.xml $color_file
rm [0-9]*.xml
